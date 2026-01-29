import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print(
      'Error: lib directory not found. Please run this script from the project root.',
    );
    exit(1);
  }

  print('Analyzing Dart files in lib/ for hardcoded UI strings...');

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart') &&
            !f.path.endsWith('.freezed.dart') &&
            !f.path.contains('/generated/') &&
            !f.path.contains('/l10n/'),
      )
      .toList();

  int issueCount = 0;

  for (final file in files) {
    try {
      final content = file.readAsStringSync();
      // Skip file if it has ignore comment at top (optional, but good practice)
      if (content.contains('// ignore_for_file: no_hardcoded_strings'))
        continue;

      final parseResult = parseString(content: content, path: file.path);
      final visitor = HardcodedStringVisitor(parseResult.lineInfo);
      parseResult.unit.visitChildren(visitor);

      if (visitor.issues.isNotEmpty) {
        // print('\nFile: ${file.path}');
        for (final issue in visitor.issues) {
          print('${file.path}:${issue.line}:${issue.column}: ${issue.message}');
          issueCount++;
        }
      }
    } catch (e) {
      print('Failed to analyze ${file.path}: $e');
    }
  }

  print('\nAnalysis complete. Found $issueCount potential hardcoded strings.');
}

class HardcodedStringVisitor extends GeneralizingAstVisitor<void> {
  final LineInfo lineInfo;
  final List<Issue> issues = [];

  HardcodedStringVisitor(this.lineInfo);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;

    // Check Text('...')
    if (typeName == 'Text') {
      if (node.argumentList.arguments.isNotEmpty) {
        final firstArg = node.argumentList.arguments.first;
        _checkStringArgument(firstArg, 'Text widget');
      }
    }

    // Check RichText/TextSpan (less common to have direct string, usually children, but check 'text' param)
    // Actually, let's catch generic Chinese characters anywhere in the UI code structure which is a strong signal.

    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitStringLiteral(StringLiteral node) {
    // Only check if it contains non-ASCII characters (e.g. Chinese)
    // This catches "例子" even if not in a Text widget directly, but maybe in a variable used by UI.
    // This is a heuristic: If it has Chinese, it PROBABLY should be localized.
    final value = node.stringValue;
    if (value != null && _containsForeignCharacters(value)) {
      // Filter out log statements if possible, but basic visitor might hit print('中文')
      // For now, report it.
      // Filter out log statements if possible, but basic visitor might hit print('中文')
      // For now, report it.
      // Try to find if parent is a method invocation of 'print' or 'log' (simple check)
      // This requires walking up, which is hard in simple visitor without parent pointers unless we keep track.
      // But let's just report all foreign strings for now, user can filter.
      _report(node, 'Contains non-ASCII characters: "$value"');
    }

    // Checking for English hardcoded strings in Text widgets is handled by visitInstanceCreationExpression
    // THIS visitor method checks specifically for the String literal itself,
    // but detecting English hardcoded strings everywhere is too noisy (e.g. JSON keys, internal IDs).
    // So for English, we rely on the specific `Text` widget check in `visitInstanceCreationExpression`.
  }

  void _checkStringArgument(Expression argument, String context) {
    if (argument is StringLiteral) {
      final value = argument.stringValue;
      if (value != null && value.isNotEmpty) {
        _report(argument, 'Hardcoded string in $context: "$value"');
      }
    }
  }

  bool _containsForeignCharacters(String s) {
    // CJK Unified Ideographs: 4E00-9FFF
    for (int i = 0; i < s.codeUnits.length; i++) {
      if (s.codeUnitAt(i) >= 0x4E00 && s.codeUnitAt(i) <= 0x9FFF) {
        return true;
      }
    }
    return false;
  }

  void _report(AstNode node, String message) {
    final location = lineInfo.getLocation(node.offset);
    issues.add(Issue(location.lineNumber, location.columnNumber, message));
  }
}

class Issue {
  final int line;
  final int column;
  final String message;
  Issue(this.line, this.column, this.message);
}
