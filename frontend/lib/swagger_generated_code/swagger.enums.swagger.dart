// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';

enum ShadowingGetGet$Response$Data$WordFeedback$ItemLevel {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('perfect')
  perfect('perfect'),
  @JsonValue('warning')
  warning('warning'),
  @JsonValue('error')
  error('error'),
  @JsonValue('missing')
  missing('missing');

  final String? value;

  const ShadowingGetGet$Response$Data$WordFeedback$ItemLevel(this.value);
}

enum ShadowingGetGetSourceType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ai_message')
  aiMessage('ai_message'),
  @JsonValue('native_expression')
  nativeExpression('native_expression'),
  @JsonValue('reference_answer')
  referenceAnswer('reference_answer');

  final String? value;

  const ShadowingGetGetSourceType(this.value);
}

enum ShadowingUpsertPut$RequestBodySourceType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ai_message')
  aiMessage('ai_message'),
  @JsonValue('native_expression')
  nativeExpression('native_expression'),
  @JsonValue('reference_answer')
  referenceAnswer('reference_answer');

  final String? value;

  const ShadowingUpsertPut$RequestBodySourceType(this.value);
}

enum ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('perfect')
  perfect('perfect'),
  @JsonValue('warning')
  warning('warning'),
  @JsonValue('error')
  error('error'),
  @JsonValue('missing')
  missing('missing');

  final String? value;

  const ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel(this.value);
}
