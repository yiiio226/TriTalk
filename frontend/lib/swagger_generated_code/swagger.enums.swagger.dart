// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';

enum ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel {
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

  const ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel(
    this.value,
  );
}

enum ShadowingSavePost$RequestBodySourceType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ai_message')
  aiMessage('ai_message'),
  @JsonValue('native_expression')
  nativeExpression('native_expression'),
  @JsonValue('reference_answer')
  referenceAnswer('reference_answer'),
  @JsonValue('custom')
  custom('custom');

  final String? value;

  const ShadowingSavePost$RequestBodySourceType(this.value);
}

enum ShadowingSavePost$RequestBody$WordFeedback$ItemLevel {
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

  const ShadowingSavePost$RequestBody$WordFeedback$ItemLevel(this.value);
}
