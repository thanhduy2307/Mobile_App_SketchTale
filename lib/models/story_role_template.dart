import '../utils/app_config.dart';
import 'backend_enums.dart';

/// Model representing StoryRoleTemplate from Swagger:
/// - GET /api/story-template/{storyId}/roles (Role Child: active roles)
/// - GET /api/role/{id} (Role Child: role by id)
/// (CM-only: all-roles, POST, PUT, DELETE)
class StoryRoleTemplate {
  final String id;
  final String storyTemplateId;
  final StoryRoleType storyRoleType;
  final String roleName;
  final String? description;
  final bool allowCustomCharacter;
  final bool requiresParentApproval;
  final String? defaultAssetUrl;
  final int? status;
  final String? createdAt;
  final String? createBy;
  final String? updatedAt;
  final String? updateBy;

  const StoryRoleTemplate({
    required this.id,
    required this.storyTemplateId,
    this.storyRoleType = StoryRoleType.mainCharacter,
    required this.roleName,
    this.description,
    this.allowCustomCharacter = true,
    this.requiresParentApproval = false,
    this.defaultAssetUrl,
    this.status,
    this.createdAt,
    this.createBy,
    this.updatedAt,
    this.updateBy,
  });

  /// Helper getter alias for roleName
  String get name => roleName;

  /// Full URL for role default visual asset
  String get fullDefaultAssetUrl => AppConfig.resolveImageUrl(defaultAssetUrl);

  /// Kid-friendly role title
  String get roleTitleWithEmoji {
    return roleName;
  }

  /// Kid-friendly type badge
  String get typeLabel {
    switch (storyRoleType) {
      case StoryRoleType.mainCharacter:
        return 'Nhân Vật Chính';
      case StoryRoleType.companion:
        return 'Bạn Đồng Hành';
      case StoryRoleType.supporting:
        return 'Nhân Vật Phụ';
      case StoryRoleType.other:
        return 'Vai Trò Khác';
    }
  }

  factory StoryRoleTemplate.fromJson(Map<String, dynamic> json) {
    int rawType = 0;
    if (json['storyRoleType'] is int) {
      rawType = json['storyRoleType'] as int;
    } else if (json['storyRoleType'] != null) {
      rawType = int.tryParse(json['storyRoleType'].toString()) ?? 0;
    }

    return StoryRoleTemplate(
      id: json['id']?.toString() ?? '',
      storyTemplateId: json['storyTemplateId']?.toString() ?? '',
      storyRoleType: StoryRoleType.fromInt(rawType),
      roleName: json['roleName']?.toString() ?? 'Nhân vật',
      description: json['description']?.toString(),
      allowCustomCharacter: json['allowCustomCharacter'] == true ||
          json['allowCustomCharacter']?.toString() == 'true',
      requiresParentApproval: json['requiresParentApproval'] == true ||
          json['requiresParentApproval']?.toString() == 'true',
      defaultAssetUrl: json['defaultAssetUrl']?.toString(),
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
      'storyRoleType': storyRoleType.index,
      'roleName': roleName,
      'description': description,
      'allowCustomCharacter': allowCustomCharacter,
      'requiresParentApproval': requiresParentApproval,
      'defaultAssetUrl': defaultAssetUrl,
      'status': status,
      'createdAt': createdAt,
      'createBy': createBy,
      'updatedAt': updatedAt,
      'updateBy': updateBy,
    };
  }

  StoryRoleTemplate copyWith({
    String? id,
    String? storyTemplateId,
    StoryRoleType? storyRoleType,
    String? roleName,
    String? description,
    bool? allowCustomCharacter,
    bool? requiresParentApproval,
    String? defaultAssetUrl,
    int? status,
    String? createdAt,
    String? createBy,
    String? updatedAt,
    String? updateBy,
  }) {
    return StoryRoleTemplate(
      id: id ?? this.id,
      storyTemplateId: storyTemplateId ?? this.storyTemplateId,
      storyRoleType: storyRoleType ?? this.storyRoleType,
      roleName: roleName ?? this.roleName,
      description: description ?? this.description,
      allowCustomCharacter: allowCustomCharacter ?? this.allowCustomCharacter,
      requiresParentApproval: requiresParentApproval ?? this.requiresParentApproval,
      defaultAssetUrl: defaultAssetUrl ?? this.defaultAssetUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createBy: createBy ?? this.createBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updateBy: updateBy ?? this.updateBy,
    );
  }
}
