#!/usr/bin/env dart
// ignore_for_file: avoid_print
/// i18n 字符串扫描工具
///
/// 扫描 Flutter 项目中需要国际化的硬编码字符串，生成：
/// 1. 迁移报告 (Markdown)
/// 2. ARB 草稿文件
///
/// 使用方式:
///   dart run scripts/i18n_scanner.dart
///
/// 输出:
///   - scripts/output/i18n_migration_report.md
///   - scripts/output/intl_en_draft.arb

import 'dart:io';
import 'dart:convert';

/// 扫描结果
class StringMatch {
  final String filePath;
  final int lineNumber;
  final String lineContent;
  final String extractedString;
  final String matchType; // Text, hintText, tooltip, etc.
  final String suggestedKey;

  StringMatch({
    required this.filePath,
    required this.lineNumber,
    required this.lineContent,
    required this.extractedString,
    required this.matchType,
    required this.suggestedKey,
  });
}

/// 扫描配置
class ScanConfig {
  /// 要扫描的目录
  static const String scanDir = 'lib';

  /// 排除的目录
  static const List<String> excludeDirs = [
    'swagger_generated_code',
    'l10n',
    '.dart_tool',
  ];

  /// 排除的文件名模式
  static const List<String> excludeFiles = ['.g.dart', '.freezed.dart'];

  /// 排除的文件路径（相对于 lib/）
  /// 这些文件包含代码示例，不需要国际化
  static const List<String> excludePaths = [
    'core/design/app_design_system.dart', // 代码注释示例
  ];

  /// 需要检测的模式
  static final List<PatternConfig> patterns = [
    // Text widget with string literal
    PatternConfig(
      name: 'Text',
      regex: RegExp(r'''Text\(\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1'''),
      stringGroup: 2,
    ),
    // hintText property
    PatternConfig(
      name: 'hintText',
      regex: RegExp(r'''hintText:\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1'''),
      stringGroup: 2,
    ),
    // tooltip property
    PatternConfig(
      name: 'tooltip',
      regex: RegExp(r'''tooltip:\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1'''),
      stringGroup: 2,
    ),
    // label: Text('...')
    PatternConfig(
      name: 'label',
      regex: RegExp(
        r'''label:\s*(?:const\s+)?Text\(\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1''',
      ),
      stringGroup: 2,
    ),
    // title: Text('...') or title: '...'
    PatternConfig(
      name: 'title',
      regex: RegExp(
        r'''title:\s*(?:const\s+)?(?:Text\(\s*)?(['"])((?:(?!\1)[^\\]|\\.)*?)\1''',
      ),
      stringGroup: 2,
    ),
    // content: Text('...')
    PatternConfig(
      name: 'content',
      regex: RegExp(
        r'''content:\s*(?:const\s+)?Text\(\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1''',
      ),
      stringGroup: 2,
    ),
    // SnackBar with Text
    PatternConfig(
      name: 'SnackBar',
      regex: RegExp(
        r'''SnackBar\([^)]*content:\s*(?:const\s+)?Text\(\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1''',
      ),
      stringGroup: 2,
    ),
    // errorText property
    PatternConfig(
      name: 'errorText',
      regex: RegExp(r'''errorText:\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1'''),
      stringGroup: 2,
    ),
    // semanticsLabel property
    PatternConfig(
      name: 'semanticsLabel',
      regex: RegExp(r'''semanticsLabel:\s*(['"])((?:(?!\1)[^\\]|\\.)*?)\1'''),
      stringGroup: 2,
    ),
  ];

  /// 应该被忽略的字符串模式
  static final List<RegExp> ignorePatterns = [
    // 纯 emoji
    RegExp(r'^[\p{Emoji}\s]+$', unicode: true),
    // 纯标点符号
    RegExp(r'^[\p{P}\s]+$', unicode: true),
    // 空字符串
    RegExp(r'^\s*$'),
    // 数字
    RegExp(r'^\d+$'),
    // 单个字符
    RegExp(r'^.$'),
    // HTTP URL
    RegExp(r'^https?://'),
    // 文件路径
    RegExp(r'^[\w\-./]+\.\w+$'),
    // 代码注释示例
    RegExp(r'^\s*//'),
    // 变量插值（包含 $）
    RegExp(r'\$\{?\w'),
  ];
}

class PatternConfig {
  final String name;
  final RegExp regex;
  final int stringGroup;

  PatternConfig({
    required this.name,
    required this.regex,
    required this.stringGroup,
  });
}

class I18nScanner {
  final List<StringMatch> matches = [];
  final Set<String> seenStrings = {};
  final Map<String, int> keyCounter = {};

  void scan() {
    final dir = Directory(ScanConfig.scanDir);
    if (!dir.existsSync()) {
      print('Error: Directory ${ScanConfig.scanDir} not found');
      exit(1);
    }

    print('🔍 Scanning ${ScanConfig.scanDir}...\n');
    _scanDirectory(dir);
    print('\n✅ Scan complete! Found ${matches.length} strings to review.\n');
  }

  void _scanDirectory(Directory dir) {
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        final dirName = entity.path.split('/').last;
        if (!ScanConfig.excludeDirs.contains(dirName)) {
          _scanDirectory(entity);
        }
      } else if (entity is File && entity.path.endsWith('.dart')) {
        // Check if file should be excluded by pattern
        final shouldExcludeByPattern = ScanConfig.excludeFiles.any(
          (pattern) => entity.path.endsWith(pattern),
        );

        // Check if file should be excluded by path
        final relativePath = entity.path.replaceFirst(
          '${ScanConfig.scanDir}/',
          '',
        );
        final shouldExcludeByPath = ScanConfig.excludePaths.contains(
          relativePath,
        );

        if (!shouldExcludeByPattern && !shouldExcludeByPath) {
          _scanFile(entity);
        }
      }
    }
  }

  void _scanFile(File file) {
    final lines = file.readAsLinesSync();
    final relativePath = file.path.replaceFirst('${ScanConfig.scanDir}/', '');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1;

      for (final pattern in ScanConfig.patterns) {
        final matches = pattern.regex.allMatches(line);
        for (final match in matches) {
          final extractedString = match.group(pattern.stringGroup);
          if (extractedString != null && _shouldInclude(extractedString)) {
            _addMatch(
              filePath: relativePath,
              lineNumber: lineNumber,
              lineContent: line.trim(),
              extractedString: extractedString,
              matchType: pattern.name,
            );
          }
        }
      }
    }
  }

  bool _shouldInclude(String str) {
    // 跳过太短的字符串
    if (str.length < 2) return false;

    // 检查是否匹配任何忽略模式
    for (final pattern in ScanConfig.ignorePatterns) {
      if (pattern.hasMatch(str)) return false;
    }

    return true;
  }

  void _addMatch({
    required String filePath,
    required int lineNumber,
    required String lineContent,
    required String extractedString,
    required String matchType,
  }) {
    // 去重（同一个字符串可能在多处出现）
    final key = '$filePath:$lineNumber:$extractedString';
    if (seenStrings.contains(key)) return;
    seenStrings.add(key);

    final suggestedKey = _generateKey(extractedString, filePath, matchType);

    matches.add(
      StringMatch(
        filePath: filePath,
        lineNumber: lineNumber,
        lineContent: lineContent,
        extractedString: extractedString,
        matchType: matchType,
        suggestedKey: suggestedKey,
      ),
    );

    // 进度显示
    stdout.write('.');
  }

  String _generateKey(String str, String filePath, String matchType) {
    // 从文件路径提取模块名
    final pathParts = filePath.split('/');
    String prefix = '';

    // 尝试从路径中提取有意义的前缀
    if (pathParts.length >= 2) {
      if (pathParts[0] == 'features' && pathParts.length >= 2) {
        prefix = pathParts[1]; // e.g., "chat", "home", "study"
      } else if (pathParts[0] == 'core') {
        prefix = 'common';
      }
    }

    // 生成基础 key
    String baseKey = _stringToKey(str);

    // 组合
    String fullKey = prefix.isEmpty ? baseKey : '${prefix}_$baseKey';

    // 处理重复
    if (keyCounter.containsKey(fullKey)) {
      keyCounter[fullKey] = keyCounter[fullKey]! + 1;
      fullKey = '${fullKey}_${keyCounter[fullKey]}';
    } else {
      keyCounter[fullKey] = 0;
    }

    return fullKey;
  }

  String _stringToKey(String str) {
    // 处理特殊情况
    str = str.replaceAll(RegExp(r'[^\w\s]'), ' '); // 移除特殊字符
    str = str.trim();

    // 拆分单词
    final words = str.split(RegExp(r'\s+'));

    // 取前 4 个单词
    final keyWords = words.take(4).map((w) => w.toLowerCase()).toList();

    // 转换为 camelCase
    if (keyWords.isEmpty) return 'unknown';

    String key = keyWords.first;
    for (int i = 1; i < keyWords.length; i++) {
      if (keyWords[i].isNotEmpty) {
        key += keyWords[i][0].toUpperCase() + keyWords[i].substring(1);
      }
    }

    return key;
  }

  void generateReport() {
    final outputDir = Directory('scripts/output');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    _generateMarkdownReport();
    _generateArbDraft();
  }

  void _generateMarkdownReport() {
    final buffer = StringBuffer();

    buffer.writeln('# i18n Migration Report');
    buffer.writeln();
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('## Summary');
    buffer.writeln();
    buffer.writeln('- **Total strings found**: ${matches.length}');
    buffer.writeln(
      '- **Files affected**: ${matches.map((m) => m.filePath).toSet().length}',
    );
    buffer.writeln();

    // 按文件分组
    final byFile = <String, List<StringMatch>>{};
    for (final match in matches) {
      byFile.putIfAbsent(match.filePath, () => []).add(match);
    }

    buffer.writeln('## Strings by File');
    buffer.writeln();

    for (final entry in byFile.entries) {
      buffer.writeln('### ${entry.key}');
      buffer.writeln();
      buffer.writeln('| Line | Type | String | Suggested Key |');
      buffer.writeln('|------|------|--------|---------------|');

      for (final match in entry.value) {
        final escapedString = match.extractedString
            .replaceAll('|', '\\|')
            .replaceAll('\n', '\\n');
        buffer.writeln(
          '| ${match.lineNumber} | ${match.matchType} | `$escapedString` | `${match.suggestedKey}` |',
        );
      }
      buffer.writeln();
    }

    // 生成快速替换参考
    buffer.writeln('## Quick Reference');
    buffer.writeln();
    buffer.writeln('After adding keys to `intl_en.arb`, replace in code:');
    buffer.writeln();
    buffer.writeln('```dart');
    buffer.writeln("// Before:");
    buffer.writeln("Text('Hello World')");
    buffer.writeln();
    buffer.writeln("// After:");
    buffer.writeln("import 'package:frontend/core/utils/l10n_ext.dart';");
    buffer.writeln("Text(context.l10n.helloWorld)");
    buffer.writeln('```');
    buffer.writeln();

    final reportFile = File('scripts/output/i18n_migration_report.md');
    reportFile.writeAsStringSync(buffer.toString());
    print('📄 Report generated: ${reportFile.path}');
  }

  void _generateArbDraft() {
    final arbMap = <String, dynamic>{'@@locale': 'en'};

    // 去重，只保留唯一的字符串
    final uniqueStrings = <String, StringMatch>{};
    for (final match in matches) {
      // 使用字符串内容作为去重 key
      if (!uniqueStrings.containsKey(match.extractedString)) {
        uniqueStrings[match.extractedString] = match;
      }
    }

    for (final match in uniqueStrings.values) {
      final key = match.suggestedKey;
      arbMap[key] = match.extractedString;
      arbMap['@$key'] = {
        'description':
            'Source: ${match.filePath}:${match.lineNumber} (${match.matchType})',
      };
    }

    final encoder = JsonEncoder.withIndent('  ');
    final arbContent = encoder.convert(arbMap);

    final arbFile = File('scripts/output/intl_en_draft.arb');
    arbFile.writeAsStringSync(arbContent);
    print('📄 ARB draft generated: ${arbFile.path}');
    print('   Contains ${uniqueStrings.length} unique strings');
  }
}

void main() {
  print('');
  print('╔════════════════════════════════════════╗');
  print('║     Flutter i18n String Scanner        ║');
  print('╚════════════════════════════════════════╝');
  print('');

  final scanner = I18nScanner();
  scanner.scan();
  scanner.generateReport();

  print('');
  print('📋 Next steps:');
  print('   1. Review scripts/output/i18n_migration_report.md');
  print('   2. Adjust keys in scripts/output/intl_en_draft.arb');
  print('   3. Copy approved entries to lib/l10n/intl_en.arb');
  print('   4. Run: flutter gen-l10n');
  print('   5. Replace hardcoded strings with context.l10n.xxx');
  print('');
}
