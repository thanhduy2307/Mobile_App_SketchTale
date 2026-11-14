// Models representing Authentication & Profile based on AUTH_CONTROLLER_README.md (v2.2)

/// Result token payload from /api/auth/login, /api/auth/login/child, and /api/auth/refresh-token
class AuthTokenData {
  final String token;
  final String refreshToken;
  final String username;
  final String? email;
  final String role; // "Child", "Parent", "Admin", "ContentManager"

  const AuthTokenData({
    required this.token,
    required this.refreshToken,
    required this.username,
    this.email,
    required this.role,
  });

  factory AuthTokenData.fromJson(Map<String, dynamic> json) {
    return AuthTokenData(
      token: json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'Child',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'username': username,
      if (email != null) 'email': email,
      'role': role,
    };
  }
}

/// Parent profile details nested within UserProfile
class ParentProfileInfo {
  final int childProfileLimit;
  final int remainingChildProfileLimit;
  final int monthlyCreditLimit;
  final int remainingMonthlyCreditLimit;
  final bool canExportStory;
  final bool accessFullStories;
  final bool subscriptionTrialPlusPlan;

  const ParentProfileInfo({
    this.childProfileLimit = 1,
    this.remainingChildProfileLimit = 1,
    this.monthlyCreditLimit = 500,
    this.remainingMonthlyCreditLimit = 500,
    this.canExportStory = false,
    this.accessFullStories = false,
    this.subscriptionTrialPlusPlan = false,
  });

  factory ParentProfileInfo.fromJson(Map<String, dynamic> json) {
    return ParentProfileInfo(
      childProfileLimit: (json['childProfileLimit'] as num?)?.toInt() ?? 1,
      remainingChildProfileLimit:
          (json['remainingChildProfileLimit'] as num?)?.toInt() ?? 1,
      monthlyCreditLimit: (json['monthlyCreditLimit'] as num?)?.toInt() ?? 500,
      remainingMonthlyCreditLimit:
          (json['remainingMonthlyCreditLimit'] as num?)?.toInt() ?? 500,
      canExportStory: json['canExportStory'] == true,
      accessFullStories: json['accessFullStories'] == true,
      subscriptionTrialPlusPlan: json['subscriptionTrialPlusPlan'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childProfileLimit': childProfileLimit,
      'remainingChildProfileLimit': remainingChildProfileLimit,
      'monthlyCreditLimit': monthlyCreditLimit,
      'remainingMonthlyCreditLimit': remainingMonthlyCreditLimit,
      'canExportStory': canExportStory,
      'accessFullStories': accessFullStories,
      'subscriptionTrialPlusPlan': subscriptionTrialPlusPlan,
    };
  }
}

/// Detailed user profile returned from GET /api/auth/profile
class UserProfile {
  final String id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? gender;
  final String role; // "Child", "Parent", "Admin", "ContentManager"
  final DateTime? createdAt;
  final ParentProfileInfo? parentProfile;
  final Map<String, dynamic>? childProfile;

  const UserProfile({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
    required this.role,
    this.createdAt,
    this.parentProfile,
    this.childProfile,
  });

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return username;
  }

  bool get isChild => role.toLowerCase() == 'child';
  bool get isParent => role.toLowerCase() == 'parent';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    ParentProfileInfo? parentInfo;
    if (json['parentProfile'] is Map<String, dynamic>) {
      parentInfo = ParentProfileInfo.fromJson(
          json['parentProfile'] as Map<String, dynamic>);
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      role: json['role']?.toString() ?? 'Child',
      createdAt: parsedCreatedAt,
      parentProfile: parentInfo,
      childProfile: json['childProfile'] is Map<String, dynamic>
          ? json['childProfile'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (parentProfile != null) 'parentProfile': parentProfile!.toJson(),
      if (childProfile != null) 'childProfile': childProfile,
    };
  }
}
