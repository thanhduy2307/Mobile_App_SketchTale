/// Backend Enums definition for SketchTale
/// Converted from C# enums to Dart enums with index matching and helpers
library;

enum CommonStatus {
  draft, // 0
  pending, // 1
  active, // 2
  inactive, // 3
  archived; // 4

  static CommonStatus fromInt(int value) {
    if (value >= 0 && value < CommonStatus.values.length) {
      return CommonStatus.values[value];
    }
    return CommonStatus.active;
  }
}

enum TargetAgeGroup {
  ag6to7, // 0: Age 6 to 7
  age8to10, // 1: Age 8 to 10
  age11to12; // 2: Age 11 to 12

  static TargetAgeGroup fromInt(int value) {
    if (value >= 0 && value < TargetAgeGroup.values.length) {
      return TargetAgeGroup.values[value];
    }
    return TargetAgeGroup.ag6to7;
  }
}

enum ReadingLevel {
  beginner, // 0
  intermediate, // 1
  advanced; // 2

  static ReadingLevel fromInt(int value) {
    if (value >= 0 && value < ReadingLevel.values.length) {
      return ReadingLevel.values[value];
    }
    return ReadingLevel.beginner;
  }
}

enum ParentApprovalStatus {
  notRequired,
  pending,
  approved,
  rejected;

  static ParentApprovalStatus fromInt(int value) {
    if (value >= 0 && value < ParentApprovalStatus.values.length) {
      return ParentApprovalStatus.values[value];
    }
    return ParentApprovalStatus.notRequired;
  }
}

enum DrawingType {
  canvas,
  uploaded;

  static DrawingType fromInt(int value) {
    if (value >= 0 && value < DrawingType.values.length) {
      return DrawingType.values[value];
    }
    return DrawingType.canvas;
  }
}

enum AIGenStatus {
  pending,
  processing,
  success,
  failed;

  static AIGenStatus fromInt(int value) {
    if (value >= 0 && value < AIGenStatus.values.length) {
      return AIGenStatus.values[value];
    }
    return AIGenStatus.pending;
  }
}

enum CharacterStatus {
  preview,
  pending,
  approved,
  rejected,
  hidden;

  static CharacterStatus fromInt(int value) {
    if (value >= 0 && value < CharacterStatus.values.length) {
      return CharacterStatus.values[value];
    }
    return CharacterStatus.preview;
  }
}

enum GeneratedStoryStatus {
  inProgress,
  completed,
  hidden;

  static GeneratedStoryStatus fromInt(int value) {
    if (value >= 0 && value < GeneratedStoryStatus.values.length) {
      return GeneratedStoryStatus.values[value];
    }
    return GeneratedStoryStatus.inProgress;
  }
}

enum StoryRoleType {
  mainCharacter,
  companion,
  supporting,
  other;

  static StoryRoleType fromInt(int value) {
    if (value >= 0 && value < StoryRoleType.values.length) {
      return StoryRoleType.values[value];
    }
    return StoryRoleType.mainCharacter;
  }
}

enum SubscriptionStatus {
  pendingPayment,
  active,
  expired,
  cancelled;

  static SubscriptionStatus fromInt(int value) {
    if (value >= 0 && value < SubscriptionStatus.values.length) {
      return SubscriptionStatus.values[value];
    }
    return SubscriptionStatus.pendingPayment;
  }
}

enum PaymentStatus {
  pending,
  success,
  failed;

  static PaymentStatus fromInt(int value) {
    if (value >= 0 && value < PaymentStatus.values.length) {
      return PaymentStatus.values[value];
    }
    return PaymentStatus.pending;
  }
}

enum MatchType {
  exact,
  contains,
  regex;

  static MatchType fromInt(int value) {
    if (value >= 0 && value < MatchType.values.length) {
      return MatchType.values[value];
    }
    return MatchType.exact;
  }
}

enum SeverityLevel {
  low,
  medium,
  high,
  blockImmediately;

  static SeverityLevel fromInt(int value) {
    if (value >= 0 && value < SeverityLevel.values.length) {
      return SeverityLevel.values[value];
    }
    return SeverityLevel.low;
  }
}

enum ModerationAction {
  reject,
  flagForReview,
  mask;

  static ModerationAction fromInt(int value) {
    if (value >= 0 && value < ModerationAction.values.length) {
      return ModerationAction.values[value];
    }
    return ModerationAction.reject;
  }
}

enum ModerationStatus {
  pending,
  approved,
  rejected,
  resolved;

  static ModerationStatus fromInt(int value) {
    if (value >= 0 && value < ModerationStatus.values.length) {
      return ModerationStatus.values[value];
    }
    return ModerationStatus.pending;
  }
}

enum ContentReportStatus {
  pending,
  processing,
  resolve,
  dismissed;

  static ContentReportStatus fromInt(int value) {
    if (value >= 0 && value < ContentReportStatus.values.length) {
      return ContentReportStatus.values[value];
    }
    return ContentReportStatus.pending;
  }
}

enum ReportTargetType {
  character,
  story,
  content;

  static ReportTargetType fromInt(int value) {
    if (value >= 0 && value < ReportTargetType.values.length) {
      return ReportTargetType.values[value];
    }
    return ReportTargetType.character;
  }
}

enum AIActionType {
  classifyImage,
  characterGenerate;

  static AIActionType fromInt(int value) {
    if (value >= 0 && value < AIActionType.values.length) {
      return AIActionType.values[value];
    }
    return AIActionType.classifyImage;
  }
}

enum CreditActionType {
  imageClassification,
  characterGeneration,
  characterRegeneration,
  storyExport;

  static CreditActionType fromInt(int value) {
    if (value >= 0 && value < CreditActionType.values.length) {
      return CreditActionType.values[value];
    }
    return CreditActionType.imageClassification;
  }
}
