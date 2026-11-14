/// DTO for allowed character types returned by AI Vision (/api/drawings/analyze)
class AiAllowedCharTypeDto {
  final String id;
  final String nameEn;
  final String? nameVi;
  final String? description;
  final String status;

  const AiAllowedCharTypeDto({
    required this.id,
    required this.nameEn,
    this.nameVi,
    this.description,
    this.status = 'Active',
  });

  /// User friendly display name (prefer Vietnamese if present, otherwise English)
  String get displayName => (nameVi != null && nameVi!.isNotEmpty) ? nameVi! : nameEn;

  /// Emoji representation based on English/Vietnamese name keywords
  String get emoji {
    final lower = '$nameEn $nameVi'.toLowerCase();
    if (lower.contains('dragon') || lower.contains('rồng')) return '🐲';
    if (lower.contains('dino') || lower.contains('khủng long')) return '🦖';
    if (lower.contains('cat') || lower.contains('mèo')) return '🐱';
    if (lower.contains('dog') || lower.contains('chó')) return '🐶';
    if (lower.contains('rabbit') || lower.contains('thỏ')) return '🐰';
    if (lower.contains('bear') || lower.contains('gấu')) return '🐻';
    if (lower.contains('lion') || lower.contains('sư tử')) return '🦁';
    if (lower.contains('tiger') || lower.contains('hổ')) return '🐯';
    if (lower.contains('bird') || lower.contains('chim')) return '🐦';
    if (lower.contains('fish') || lower.contains('cá')) return '🐟';
    if (lower.contains('robot')) return '🤖';
    if (lower.contains('hero') || lower.contains('dũng sĩ') || lower.contains('hiệp sĩ')) return '⚔️';
    if (lower.contains('fairy') || lower.contains('phù thủy') || lower.contains('tiên')) return '🧚';
    return '✨';
  }

  factory AiAllowedCharTypeDto.fromJson(Map<String, dynamic> json) {
    return AiAllowedCharTypeDto(
      id: json['id']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? json['name']?.toString() ?? '',
      nameVi: json['name']?.toString() ?? json['nameVi']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      if (nameVi != null) 'name': nameVi,
      if (description != null) 'description': description,
      'status': status,
    };
  }
}

/// Response returned by Stage 1: POST /api/drawings/analyze
class AnalyzeDrawingResponse {
  final String drawingId;
  final String originalImageUrl;
  final String drawingType;
  final bool isRecognized;
  final List<AiAllowedCharTypeDto> suggestedCharTypes;
  final List<String> detectedTags;
  final String? standardizedPrompt;
  final int? remainingParentCredits;
  final int? remainingDailyCharacterLimit;

  const AnalyzeDrawingResponse({
    required this.drawingId,
    required this.originalImageUrl,
    required this.drawingType,
    required this.isRecognized,
    this.suggestedCharTypes = const [],
    this.detectedTags = const [],
    this.standardizedPrompt,
    this.remainingParentCredits,
    this.remainingDailyCharacterLimit,
  });

  factory AnalyzeDrawingResponse.fromJson(Map<String, dynamic> json) {
    final rawSuggested = json['suggestedCharTypes'] as List<dynamic>? ?? [];
    final suggested = rawSuggested
        .whereType<Map<String, dynamic>>()
        .map((item) => AiAllowedCharTypeDto.fromJson(item))
        .toList();

    final rawTags = json['detectedTags'] as List<dynamic>? ?? [];
    final tags = rawTags.map((e) => e.toString()).toList();

    return AnalyzeDrawingResponse(
      drawingId: json['drawingId']?.toString() ?? '',
      originalImageUrl: json['originalImageUrl']?.toString() ?? '',
      drawingType: json['drawingType']?.toString() ?? 'Canvas',
      isRecognized: json['isRecognized'] == true,
      suggestedCharTypes: suggested,
      detectedTags: tags,
      standardizedPrompt: json['standardizedPrompt']?.toString(),
      remainingParentCredits: (json['remainingParentCredits'] as num?)?.toInt(),
      remainingDailyCharacterLimit: (json['remainingDailyCharacterLimit'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drawingId': drawingId,
      'originalImageUrl': originalImageUrl,
      'drawingType': drawingType,
      'isRecognized': isRecognized,
      'suggestedCharTypes': suggestedCharTypes.map((e) => e.toJson()).toList(),
      'detectedTags': detectedTags,
      if (standardizedPrompt != null) 'standardizedPrompt': standardizedPrompt,
      if (remainingParentCredits != null) 'remainingParentCredits': remainingParentCredits,
      if (remainingDailyCharacterLimit != null) 'remainingDailyCharacterLimit': remainingDailyCharacterLimit,
    };
  }
}

/// Request body for Stage 2: POST /api/drawings/generate-character
class GenerateCharacterRequest {
  final String drawingId;
  final String charTypeId;
  final String? standardizedPrompt;
  final String? childAdditionalIdea;
  final List<String>? detectedTags;
  final bool isRegenerate;

  const GenerateCharacterRequest({
    required this.drawingId,
    required this.charTypeId,
    this.standardizedPrompt,
    this.childAdditionalIdea,
    this.detectedTags,
    this.isRegenerate = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'drawingId': drawingId,
      'charTypeId': charTypeId,
      if (standardizedPrompt != null && standardizedPrompt!.isNotEmpty)
        'standardizedPrompt': standardizedPrompt,
      if (childAdditionalIdea != null && childAdditionalIdea!.isNotEmpty)
        'childAdditionalIdea': childAdditionalIdea,
      if (detectedTags != null && detectedTags!.isNotEmpty)
        'detectedTags': detectedTags,
      'isRegenerate': isRegenerate,
    };
  }
}

/// Response returned by Stage 2: POST /api/drawings/generate-character
class GenerateCharacterResponse {
  final String aiCharacterGenerateId;
  final String characterId;
  final String drawingId;
  final String charTypeId;
  final String generateImageUrl;
  final String aiPromptUsed;
  final String aiGenStatus;
  final String characterStatus;
  final int? remainingParentCredits;
  final int? remainingDailyCharacterLimit;

  const GenerateCharacterResponse({
    required this.aiCharacterGenerateId,
    required this.characterId,
    required this.drawingId,
    required this.charTypeId,
    required this.generateImageUrl,
    required this.aiPromptUsed,
    required this.aiGenStatus,
    required this.characterStatus,
    this.remainingParentCredits,
    this.remainingDailyCharacterLimit,
  });

  factory GenerateCharacterResponse.fromJson(Map<String, dynamic> json) {
    return GenerateCharacterResponse(
      aiCharacterGenerateId: json['aiCharacterGenerateId']?.toString() ?? '',
      characterId: json['characterId']?.toString() ?? '',
      drawingId: json['drawingId']?.toString() ?? '',
      charTypeId: json['charTypeId']?.toString() ?? '',
      generateImageUrl: json['generateImageUrl']?.toString() ?? '',
      aiPromptUsed: json['aiPromptUsed']?.toString() ?? '',
      aiGenStatus: json['aiGenStatus']?.toString() ?? 'Success',
      characterStatus: json['characterStatus']?.toString() ?? 'Preview',
      remainingParentCredits: (json['remainingParentCredits'] as num?)?.toInt(),
      remainingDailyCharacterLimit: (json['remainingDailyCharacterLimit'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiCharacterGenerateId': aiCharacterGenerateId,
      'characterId': characterId,
      'drawingId': drawingId,
      'charTypeId': charTypeId,
      'generateImageUrl': generateImageUrl,
      'aiPromptUsed': aiPromptUsed,
      'aiGenStatus': aiGenStatus,
      'characterStatus': characterStatus,
      if (remainingParentCredits != null) 'remainingParentCredits': remainingParentCredits,
      if (remainingDailyCharacterLimit != null) 'remainingDailyCharacterLimit': remainingDailyCharacterLimit,
    };
  }
}

/// Log model for GET /api/credit-transaction-logs
class CreditTransactionLog {
  final String id;
  final String parentProfileId;
  final String actionType; // "Spend", "Refund", "Deposit"
  final String? featureKey; // "ImageClassification", "CharacterGeneration", "CharacterRegeneration"
  final int amount;
  final int creditBefore;
  final int creditAfter;
  final String description;
  final String? createdAt;

  const CreditTransactionLog({
    required this.id,
    required this.parentProfileId,
    required this.actionType,
    this.featureKey,
    required this.amount,
    required this.creditBefore,
    required this.creditAfter,
    required this.description,
    this.createdAt,
  });

  factory CreditTransactionLog.fromJson(Map<String, dynamic> json) {
    return CreditTransactionLog(
      id: json['id']?.toString() ?? '',
      parentProfileId: json['parentProfileId']?.toString() ?? '',
      actionType: json['actionType']?.toString() ?? 'Spend',
      featureKey: json['featureKey']?.toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      creditBefore: (json['creditBefore'] as num?)?.toInt() ?? 0,
      creditAfter: (json['creditAfter'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentProfileId': parentProfileId,
      'actionType': actionType,
      if (featureKey != null) 'featureKey': featureKey,
      'amount': amount,
      'creditBefore': creditBefore,
      'creditAfter': creditAfter,
      'description': description,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
