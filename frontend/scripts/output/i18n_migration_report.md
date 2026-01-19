# i18n Migration Report

Generated: 2026-01-19T13:51:20.652526

## Summary

- **Total strings found**: 2
- **Files affected**: 2

## Strings by File

### core/widgets/error_screen.dart

| Line | Type | String | Suggested Key |
|------|------|--------|---------------|
| 13 | title | `TriTalk - Error` | `common_tritalkError` |

### main.dart

| Line | Type | String | Suggested Key |
|------|------|--------|---------------|
| 82 | title | `TriTalk` | `tritalk` |

## Quick Reference

After adding keys to `intl_en.arb`, replace in code:

```dart
// Before:
Text('Hello World')

// After:
import 'package:frontend/core/utils/l10n_ext.dart';
Text(context.l10n.helloWorld)
```

