import 'backend_enums.dart';

/// Represents a UserStoryCharacterMapping from /api/user-story-character-mappings
class UserStoryCharacterMapping {
  final String id;
  final String generatedStoryId;
  final String storyRoleTemplateId;
  final String characterId;
  final ParentApprovalStatus parentApprovalStatus;
  final String? createdAt;

  const UserStoryCharacterMapping({
    required this.id,
    required this.generatedStoryId,
    required this.storyRoleTemplateId,
    required this.characterId,
    this.parentApprovalStatus = ParentApprovalStatus.notRequired,
    this.createdAt,
  });

  factory UserStoryCharacterMapping.fromJson(Map<String, dynamic> json) {
    final statusVal = json['parentApprovalStatus'];
    ParentApprovalStatus parsedStatus = ParentApprovalStatus.notRequired;
    if (statusVal is int) {
      parsedStatus = ParentApprovalStatus.fromInt(statusVal);
    } else if (statusVal is String) {
      switch (statusVal.toLowerCase()) {
        case 'notrequired':
          parsedStatus = ParentApprovalStatus.notRequired;
          break;
        case 'pending':
          parsedStatus = ParentApprovalStatus.pending;
          break;
        case 'approved':
          parsedStatus = ParentApprovalStatus.approved;
          break;
        case 'rejected':
          parsedStatus = ParentApprovalStatus.rejected;
          break;
      }
    }

    return UserStoryCharacterMapping(
      id: json['id']?.toString() ?? '',
      generatedStoryId: json['generatedStoryId']?.toString() ?? '',
      storyRoleTemplateId: json['storyRoleTemplateId']?.toString() ?? '',
      characterId: json['characterId']?.toString() ?? '',
      parentApprovalStatus: parsedStatus,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'generatedStoryId': generatedStoryId,
      'storyRoleTemplateId': storyRoleTemplateId,
      'characterId': characterId,
      'parentApprovalStatus': parentApprovalStatus.index,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toCreateDto() {
    return {
      'generatedStoryId': generatedStoryId,
      'storyRoleTemplateId': storyRoleTemplateId,
      'characterId': characterId,
    };
  }

  bool get isApproved =>
      parentApprovalStatus == ParentApprovalStatus.approved ||
      parentApprovalStatus == ParentApprovalStatus.notRequired;

  bool get isPending => parentApprovalStatus == ParentApprovalStatus.pending;
}
