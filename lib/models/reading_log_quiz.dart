/// Models for the Reading Log / Child Quiz Answer API
/// (`ReadingLogController` -> `/api/reading-logs/...`, Child & Parent roles).
library;

int _asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic v, [double fallback = 0.0]) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  return v?.toString().toLowerCase() == 'true';
}

/// Response of `POST /api/reading-logs/child-quiz-answers` (`SubmitQuizAnswerResponseDto`).
/// The backend grades the answer, so the app should trust [isCorrect] / [stars].
class SubmitQuizAnswerResult {
  final String id;
  final String childProfileId;
  final String readingLogId;
  final String storyQuizTemplateId;
  final int selectedOptionIndex;
  final int correctOptionIndex;
  final bool isCorrect;
  final int quizScore;
  final int responseTimeSeconds;
  final String message;
  final int currentAnsweredCount;
  final int totalQuestions;
  final double completionPercentage;
  final bool isQuizCompleted;

  /// 0 until the whole quiz is finished, then 1..3.
  final int stars;

  const SubmitQuizAnswerResult({
    this.id = '',
    this.childProfileId = '',
    this.readingLogId = '',
    this.storyQuizTemplateId = '',
    this.selectedOptionIndex = 0,
    this.correctOptionIndex = 0,
    this.isCorrect = false,
    this.quizScore = 0,
    this.responseTimeSeconds = 0,
    this.message = '',
    this.currentAnsweredCount = 0,
    this.totalQuestions = 0,
    this.completionPercentage = 0,
    this.isQuizCompleted = false,
    this.stars = 0,
  });

  factory SubmitQuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return SubmitQuizAnswerResult(
      id: json['id']?.toString() ?? '',
      childProfileId: json['childProfileId']?.toString() ?? '',
      readingLogId: json['readingLogId']?.toString() ?? '',
      storyQuizTemplateId: json['storyQuizTemplateId']?.toString() ?? '',
      selectedOptionIndex: _asInt(json['selectedOptionIndex']),
      correctOptionIndex: _asInt(json['correctOptionIndex']),
      isCorrect: _asBool(json['isCorrect']),
      quizScore: _asInt(json['quizScore']),
      responseTimeSeconds: _asInt(json['responseTimeSeconds']),
      message: json['message']?.toString() ?? '',
      currentAnsweredCount: _asInt(json['currentAnsweredCount']),
      totalQuestions: _asInt(json['totalQuestions']),
      completionPercentage: _asDouble(json['completionPercentage']),
      isQuizCompleted: _asBool(json['isQuizCompleted']),
      stars: _asInt(json['stars']),
    );
  }
}

/// One answered question inside a reading log (`ChildQuizAnswerDto`).
class ChildQuizAnswerDetail {
  final String storyQuizTemplateId;
  final int selectedOptionIndex;
  final int correctOptionIndex;
  final bool isCorrect;
  final int quizScore;
  final int responseTimeSeconds;
  final String? questionText;
  final String? questionAudioUrl;
  final String? questionPicUrl;
  final List<String> options;

  const ChildQuizAnswerDetail({
    this.storyQuizTemplateId = '',
    this.selectedOptionIndex = 0,
    this.correctOptionIndex = 0,
    this.isCorrect = false,
    this.quizScore = 0,
    this.responseTimeSeconds = 0,
    this.questionText,
    this.questionAudioUrl,
    this.questionPicUrl,
    this.options = const [],
  });

  factory ChildQuizAnswerDetail.fromJson(Map<String, dynamic> json) {
    return ChildQuizAnswerDetail(
      storyQuizTemplateId: json['storyQuizTemplateId']?.toString() ?? '',
      selectedOptionIndex: _asInt(json['selectedOptionIndex']),
      correctOptionIndex: _asInt(json['correctOptionIndex']),
      isCorrect: _asBool(json['isCorrect']),
      quizScore: _asInt(json['quizScore']),
      responseTimeSeconds: _asInt(json['responseTimeSeconds']),
      questionText: json['questionText']?.toString(),
      questionAudioUrl: json['questionAudioUrl']?.toString(),
      questionPicUrl: json['questionPicUrl']?.toString(),
      options: json['options'] is List
          ? (json['options'] as List).map((e) => e?.toString() ?? '').toList()
          : const [],
    );
  }
}

/// Quiz summary of one reading session (`ReadingLogQuizSummaryDto`).
class ReadingLogQuizSummary {
  final String readingLogId;
  final String childProfileId;
  final int totalQuestions;
  final int totalAnswered;
  final int totalCorrectAnswers;
  final double completionPercentage;
  final double accuracyPercentage;
  final bool isQuizCompleted;
  final int stars;
  final List<ChildQuizAnswerDetail> answers;

  const ReadingLogQuizSummary({
    this.readingLogId = '',
    this.childProfileId = '',
    this.totalQuestions = 0,
    this.totalAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.completionPercentage = 0,
    this.accuracyPercentage = 0,
    this.isQuizCompleted = false,
    this.stars = 0,
    this.answers = const [],
  });

  factory ReadingLogQuizSummary.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    return ReadingLogQuizSummary(
      readingLogId: json['readingLogId']?.toString() ?? '',
      childProfileId: json['childProfileId']?.toString() ?? '',
      totalQuestions: _asInt(json['totalQuestions']),
      totalAnswered: _asInt(json['totalAnswered']),
      totalCorrectAnswers: _asInt(json['totalCorrectAnswers']),
      completionPercentage: _asDouble(json['completionPercentage']),
      accuracyPercentage: _asDouble(json['accuracyPercentage']),
      isQuizCompleted: _asBool(json['isQuizCompleted']),
      stars: _asInt(json['stars']),
      answers: rawAnswers is List
          ? rawAnswers
              .whereType<Map>()
              .map((e) => ChildQuizAnswerDetail.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

/// Model representing an active reading session returned by `/api/reading-logs`.
class ReadingLogSession {
  final String id;
  final String childProfileId;
  final String generatedStoryId;
  final String storyTemplateId;
  final String storyTitle;
  final String coverImageUrl;
  final int totalPageNumbers;
  final int currentPage;
  final int readDurationSeconds;
  final bool isCompleted;

  const ReadingLogSession({
    this.id = '',
    this.childProfileId = '',
    this.generatedStoryId = '',
    this.storyTemplateId = '',
    this.storyTitle = '',
    this.coverImageUrl = '',
    this.totalPageNumbers = 0,
    this.currentPage = 1,
    this.readDurationSeconds = 0,
    this.isCompleted = false,
  });

  factory ReadingLogSession.fromJson(Map<String, dynamic> json) {
    return ReadingLogSession(
      id: json['id']?.toString() ?? '',
      childProfileId: json['childProfileId']?.toString() ?? '',
      generatedStoryId: json['generatedStoryId']?.toString() ?? '',
      storyTemplateId: json['storyTemplateId']?.toString() ?? '',
      storyTitle: json['storyTitle']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString() ?? '',
      totalPageNumbers: _asInt(json['totalPageNumbers']),
      currentPage: _asInt(json['currentPage'], 1),
      readDurationSeconds: _asInt(json['readDurationSeconds']),
      isCompleted: _asBool(json['isCompleted']),
    );
  }
}

/// Model representing a completed story returned by `GET /api/reading-logs/child-profiles/{childProfileId}/completed`.
class CompletedReadingLog {
  final String id;
  final String childProfileId;
  final String generatedStoryId;
  final String storyTemplateId;
  final String storyTitle;
  final String? description;
  final String coverImageUrl;
  final int totalPageNumbers;
  final int lastPageRead;
  final bool isFavorite;
  final int readDurationSeconds;
  final bool isCompleted;
  final DateTime? completedAt;

  const CompletedReadingLog({
    this.id = '',
    this.childProfileId = '',
    this.generatedStoryId = '',
    this.storyTemplateId = '',
    this.storyTitle = '',
    this.description,
    this.coverImageUrl = '',
    this.totalPageNumbers = 0,
    this.lastPageRead = 0,
    this.isFavorite = false,
    this.readDurationSeconds = 0,
    this.isCompleted = true,
    this.completedAt,
  });

  factory CompletedReadingLog.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    if (json['completedAt'] != null) {
      dt = DateTime.tryParse(json['completedAt'].toString());
    }
    return CompletedReadingLog(
      id: json['id']?.toString() ?? '',
      childProfileId: json['childProfileId']?.toString() ?? '',
      generatedStoryId: json['generatedStoryId']?.toString() ?? '',
      storyTemplateId: json['storyTemplateId']?.toString() ?? '',
      storyTitle: json['storyTitle']?.toString() ?? '',
      description: json['description']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString() ?? '',
      totalPageNumbers: _asInt(json['totalPageNumbers']),
      lastPageRead: _asInt(json['lastPageRead']),
      isFavorite: _asBool(json['isFavorite']),
      readDurationSeconds: _asInt(json['readDurationSeconds']),
      isCompleted: _asBool(json['isCompleted']),
      completedAt: dt,
    );
  }
}

