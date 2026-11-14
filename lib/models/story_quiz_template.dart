import 'dart:convert';

import '../utils/app_config.dart';
import 'models.dart';

/// Model representing StoryQuizTemplate from Swagger:
/// - GET /api/story-template/{storyId}/quizzes
/// - GET /api/story-quiz/{id}
/// - (Parent-only endpoints on Web: POST, PUT, DELETE)
class StoryQuizTemplate {
  final String id;
  final String storyTemplateId;
  final String questionText;
  final String? questionAudioUrl;
  final String? questionPicUrl;
  final String? optionsJson;
  final List<String> options;
  final int correctOptionIndex;
  final int? status;
  final String? createdAt;
  final String? createBy;
  final String? updatedAt;
  final String? updateBy;

  const StoryQuizTemplate({
    required this.id,
    required this.storyTemplateId,
    required this.questionText,
    this.questionAudioUrl,
    this.questionPicUrl,
    this.optionsJson,
    this.options = const [],
    this.correctOptionIndex = 0,
    this.status,
    this.createdAt,
    this.createBy,
    this.updatedAt,
    this.updateBy,
  });

  /// Resolves question picture URL to full server URL
  String get fullPicUrl => AppConfig.resolveImageUrl(questionPicUrl);

  /// Resolves question audio URL to full server URL
  String get fullAudioUrl => AppConfig.resolveImageUrl(questionAudioUrl);

  factory StoryQuizTemplate.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];
    if (json['options'] is List) {
      parsedOptions = (json['options'] as List)
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (parsedOptions.isEmpty && json['optionsJson'] != null) {
      try {
        final decoded = jsonDecode(json['optionsJson'].toString());
        if (decoded is List) {
          parsedOptions = decoded
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }

    return StoryQuizTemplate(
      id: json['id']?.toString() ?? '',
      storyTemplateId: json['storyTemplateId']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      questionAudioUrl: json['questionAudioUrl']?.toString(),
      questionPicUrl: json['questionPicUrl']?.toString(),
      optionsJson: json['optionsJson']?.toString(),
      options: parsedOptions,
      correctOptionIndex: json['correctOptionIndex'] is int
          ? json['correctOptionIndex'] as int
          : int.tryParse(json['correctOptionIndex']?.toString() ?? '0') ?? 0,
      status: json['status'] is int ? json['status'] as int : null,
      createdAt: json['createdAt']?.toString(),
      createBy: json['createBy']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      updateBy: json['updateBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyTemplateId': storyTemplateId,
      'questionText': questionText,
      'questionAudioUrl': questionAudioUrl,
      'questionPicUrl': questionPicUrl,
      'optionsJson': optionsJson,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'status': status,
      'createdAt': createdAt,
      'createBy': createBy,
      'updatedAt': updatedAt,
      'updateBy': updateBy,
    };
  }

  StoryQuizTemplate copyWith({
    String? id,
    String? storyTemplateId,
    String? questionText,
    String? questionAudioUrl,
    String? questionPicUrl,
    String? optionsJson,
    List<String>? options,
    int? correctOptionIndex,
    int? status,
    String? createdAt,
    String? createBy,
    String? updatedAt,
    String? updateBy,
  }) {
    return StoryQuizTemplate(
      id: id ?? this.id,
      storyTemplateId: storyTemplateId ?? this.storyTemplateId,
      questionText: questionText ?? this.questionText,
      questionAudioUrl: questionAudioUrl ?? this.questionAudioUrl,
      questionPicUrl: questionPicUrl ?? this.questionPicUrl,
      optionsJson: optionsJson ?? this.optionsJson,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createBy: createBy ?? this.createBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updateBy: updateBy ?? this.updateBy,
    );
  }

  /// Converts this backend template into the app's interactive QuizQuestion
  QuizQuestion toQuizQuestion({int rewardStars = 10, String? hint}) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    final details = <QuizOptionDetail>[];
    final validOptions = options.isNotEmpty
        ? options
        : const [
            'Tinh thần học hỏi & yêu thương',
            'Luôn vui vẻ và lạc quan',
            'Cùng nhau chia sẻ điều tốt lành',
            'Cả 3 điều trên đều đúng!',
          ];

    for (int i = 0; i < validOptions.length; i++) {
      final letter = i < letters.length ? letters[i] : '${i + 1}';
      final raw = validOptions[i];
      final title = raw.startsWith('$letter.') ? raw : '$letter. $raw';
      details.add(
        QuizOptionDetail(
          letter: letter,
          title: title,
          subtitle: i == correctOptionIndex
              ? 'Lựa chọn xuất sắc'
              : 'Thử suy nghĩ lại nhé',
          imageUrl: fullPicUrl,
        ),
      );
    }

    final safeCorrect = correctOptionIndex.clamp(0, validOptions.length - 1);

    return QuizQuestion(
      questionText: questionText.isNotEmpty
          ? questionText
          : 'Bé đã học được điều gì thú vị qua câu chuyện này nhỉ?',
      visualClueUrl: fullPicUrl,
      options: validOptions,
      optionEmojis: List.filled(validOptions.length, ''),
      optionDetails: details,
      correctIndex: safeCorrect,
      celebrationTitle: 'Bé Giỏi Lắm!',
      celebrationMessage:
          'Bé đã trả lời chính xác câu hỏi và ghi nhớ bài học thật tuyệt vời!',
      rewardStars: rewardStars,
      hint: hint ?? 'Bé hãy nhớ lại những tình huống diễn ra trong truyện nhé!',
    );
  }
}
