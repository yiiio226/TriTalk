import 'package:flutter/material.dart';

/// 发音评估结果模型
/// Pronunciation assessment result model
class PronunciationResult {
  /// 语音识别状态 (Success, Error, etc.)
  final String recognitionStatus;

  /// 识别出的文本
  final String displayText;

  /// 综合发音评分 (0-100)
  final double pronunciationScore;

  /// 准确度评分 (0-100)
  final double accuracyScore;

  /// 流利度评分 (0-100)
  final double fluencyScore;

  /// 完整度评分 (0-100)
  final double completenessScore;

  /// 语调/韵律评分 (0-100, 可选)
  final double? prosodyScore;

  /// 单词级反馈列表
  final List<WordFeedback> wordFeedback;

  PronunciationResult({
    required this.recognitionStatus,
    required this.displayText,
    required this.pronunciationScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    this.prosodyScore,
    required this.wordFeedback,
  });

  factory PronunciationResult.fromJson(Map<String, dynamic> json) {
    return PronunciationResult(
      recognitionStatus: json['recognition_status'] as String? ?? 'Unknown',
      displayText: json['display_text'] as String? ?? '',
      pronunciationScore:
          (json['pronunciation_score'] as num?)?.toDouble() ?? 0.0,
      accuracyScore: (json['accuracy_score'] as num?)?.toDouble() ?? 0.0,
      fluencyScore: (json['fluency_score'] as num?)?.toDouble() ?? 0.0,
      completenessScore:
          (json['completeness_score'] as num?)?.toDouble() ?? 0.0,
      prosodyScore: json['prosody_score'] != null
          ? (json['prosody_score'] as num).toDouble()
          : null,
      wordFeedback:
          (json['word_feedback'] as List<dynamic>?)
              ?.map((w) => WordFeedback.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'recognition_status': recognitionStatus,
    'display_text': displayText,
    'pronunciation_score': pronunciationScore,
    'accuracy_score': accuracyScore,
    'fluency_score': fluencyScore,
    'completeness_score': completenessScore,
    'prosody_score': prosodyScore,
    'word_feedback': wordFeedback.map((w) => w.toJson()).toList(),
  };

  /// 是否识别成功
  bool get isSuccess => recognitionStatus == 'Success';

  /// 获取整体评分等级
  FeedbackLevel get overallLevel => FeedbackLevel.fromScore(pronunciationScore);
}

/// 单词反馈模型 (Traffic Light 系统)
/// Word feedback model with traffic light scoring
class WordFeedback {
  /// 单词文本
  final String text;

  /// 准确度评分 (0-100)
  final double score;

  /// 评分等级 (perfect, warning, error, missing)
  final String level;

  /// 错误类型 (None, Omission, Insertion, Mispronunciation)
  final String errorType;

  /// 音素级反馈列表
  final List<PhonemeFeedback> phonemes;

  WordFeedback({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    required this.phonemes,
  });

  factory WordFeedback.fromJson(Map<String, dynamic> json) {
    return WordFeedback(
      text: json['text'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String? ?? 'error',
      errorType: json['error_type'] as String? ?? 'None',
      phonemes:
          (json['phonemes'] as List<dynamic>?)
              ?.map((p) => PhonemeFeedback.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'score': score,
    'level': level,
    'error_type': errorType,
    'phonemes': phonemes.map((p) => p.toJson()).toList(),
  };

  /// 获取单词颜色 (Traffic Light)
  Color get color {
    switch (level) {
      case 'perfect':
        return const Color(0xFF4CAF50); // Green
      case 'warning':
        return const Color(0xFFFF9800); // Orange
      case 'error':
        return const Color(0xFFF44336); // Red
      case 'missing':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return const Color(0xFF212121); // Black
    }
  }

  /// 获取反馈等级枚举
  FeedbackLevel get feedbackLevel => FeedbackLevel.fromLevel(level);

  /// 是否有发音问题
  bool get hasIssue => level != 'perfect';

  /// 是否被遗漏
  bool get isOmitted => errorType == 'Omission';

  /// 获取问题音素列表 (评分低于80的音素)
  List<PhonemeFeedback> get problemPhonemes =>
      phonemes.where((p) => p.accuracyScore < 80).toList();
}

/// 音素反馈模型
/// Phoneme-level feedback model
class PhonemeFeedback {
  /// IPA 音标
  final String phoneme;

  /// 准确度评分 (0-100)
  final double accuracyScore;

  /// 音素在音频中的偏移量 (毫秒, 可选)
  final int? offset;

  /// 音素持续时间 (毫秒, 可选)
  final int? duration;

  PhonemeFeedback({
    required this.phoneme,
    required this.accuracyScore,
    this.offset,
    this.duration,
  });

  factory PhonemeFeedback.fromJson(Map<String, dynamic> json) {
    return PhonemeFeedback(
      phoneme: json['phoneme'] as String? ?? '',
      accuracyScore: (json['accuracy_score'] as num?)?.toDouble() ?? 0.0,
      offset: json['offset'] as int?,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'phoneme': phoneme,
    'accuracy_score': accuracyScore,
    'offset': offset,
    'duration': duration,
  };

  /// 获取反馈等级
  FeedbackLevel get feedbackLevel => FeedbackLevel.fromScore(accuracyScore);

  /// 获取音素颜色
  Color get color => feedbackLevel.color;

  /// 是否有问题
  bool get hasIssue => accuracyScore < 80;
}

/// 反馈等级枚举
/// Feedback level enum for traffic light system
enum FeedbackLevel {
  perfect,
  warning,
  error,
  missing;

  /// 从分数获取等级
  static FeedbackLevel fromScore(double score) {
    if (score > 80) return FeedbackLevel.perfect;
    if (score >= 60) return FeedbackLevel.warning;
    return FeedbackLevel.error;
  }

  /// 从字符串获取等级
  static FeedbackLevel fromLevel(String level) {
    switch (level.toLowerCase()) {
      case 'perfect':
        return FeedbackLevel.perfect;
      case 'warning':
        return FeedbackLevel.warning;
      case 'error':
        return FeedbackLevel.error;
      case 'missing':
        return FeedbackLevel.missing;
      default:
        return FeedbackLevel.error;
    }
  }

  /// 获取对应颜色
  Color get color {
    switch (this) {
      case FeedbackLevel.perfect:
        return const Color(0xFF4CAF50); // Green
      case FeedbackLevel.warning:
        return const Color(0xFFFF9800); // Orange
      case FeedbackLevel.error:
        return const Color(0xFFF44336); // Red
      case FeedbackLevel.missing:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// 获取显示文本
  String get displayText {
    switch (this) {
      case FeedbackLevel.perfect:
        return 'Perfect';
      case FeedbackLevel.warning:
        return 'Needs Practice';
      case FeedbackLevel.error:
        return 'Needs Work';
      case FeedbackLevel.missing:
        return 'Missing';
    }
  }

  /// 获取图标
  IconData get icon {
    switch (this) {
      case FeedbackLevel.perfect:
        return Icons.check_circle;
      case FeedbackLevel.warning:
        return Icons.warning;
      case FeedbackLevel.error:
        return Icons.error;
      case FeedbackLevel.missing:
        return Icons.remove_circle_outline;
    }
  }
}
