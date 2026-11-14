import '../utils/app_config.dart';

/// Model representing VocabularyTemplate from Swagger
/// GET /api/story-pages/{pageId}/vocabularies
/// GET / PUT / DELETE /api/story-vocabulary/{id}
class VocabularyTemplate {
  final String id;
  final String storyPageTemplateId;
  final String word;
  final String meaning;
  final String? audioUrl;
  final String? createdAt;
  final String? createBy;
  final String? updatedAt;
  final String? updateBy;

  const VocabularyTemplate({
    required this.id,
    required this.storyPageTemplateId,
    required this.word,
    required this.meaning,
    this.audioUrl,
    this.createdAt,
    this.createBy,
    this.updatedAt,
    this.updateBy,
  });

  factory VocabularyTemplate.fromJson(Map<String, dynamic> json) {
    return VocabularyTemplate(
      id: json['id']?.toString() ?? '',
      storyPageTemplateId: json['storyPageTemplateId']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      audioUrl: json['audioUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
      createBy: json['createBy']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      updateBy: json['updateBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyPageTemplateId': storyPageTemplateId,
      'word': word,
      'meaning': meaning,
      'audioUrl': audioUrl,
      'createdAt': createdAt,
      'createBy': createBy,
      'updatedAt': updatedAt,
      'updateBy': updateBy,
    };
  }

  VocabularyTemplate copyWith({
    String? id,
    String? storyPageTemplateId,
    String? word,
    String? meaning,
    String? audioUrl,
    String? createdAt,
    String? createBy,
    String? updatedAt,
    String? updateBy,
  }) {
    return VocabularyTemplate(
      id: id ?? this.id,
      storyPageTemplateId: storyPageTemplateId ?? this.storyPageTemplateId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      audioUrl: audioUrl ?? this.audioUrl,
      createdAt: createdAt ?? this.createdAt,
      createBy: createBy ?? this.createBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updateBy: updateBy ?? this.updateBy,
    );
  }

  /// Resolves audio URL
  String get fullAudioUrl => AppConfig.resolveImageUrl(audioUrl);
}
