/// Model representing ChildProfile from Swagger /api/child-profiles
class ChildProfile {
  final String id;
  final String? userId;
  final String nickName;
  final String targetAgeGroup;
  final String readingLevel;
  final int dailyTimeLimit;
  final int remainingTimeLimit;
  final int dailyCharacterLimit;
  final int remainingCharacterLimit;
  final String avatarEmoji;
  final String? avatarUrl;
  final int stars;
  final int streakDays;

  const ChildProfile({
    required this.id,
    this.userId,
    required this.nickName,
    this.targetAgeGroup = '1',
    this.readingLevel = 'Cơ bản',
    this.dailyTimeLimit = 45,
    this.remainingTimeLimit = 45,
    this.dailyCharacterLimit = 5,
    this.remainingCharacterLimit = 5,
    this.avatarEmoji = '👶',
    this.avatarUrl,
    this.stars = 120,
    this.streakDays = 3,
  });

  /// Parse from Backend ChildProfile JSON
  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final dailyTime = json['dailyTimeLimit'] is int
        ? json['dailyTimeLimit'] as int
        : int.tryParse(json['dailyTimeLimit']?.toString() ?? '') ?? 45;

    final remainingTime = json['remainingTimeLimit'] is int
        ? json['remainingTimeLimit'] as int
        : int.tryParse(json['remainingTimeLimit']?.toString() ?? '') ??
              dailyTime;

    return ChildProfile(
      id: json['nameid']?.toString() ??
          json['childProfileId']?.toString() ??
          json['id']?.toString() ??
          '',
      userId: json['userId']?.toString() ??
          json['accountId']?.toString() ??
          json['user_id']?.toString(),
      nickName:
          json['nickName']?.toString() ??
          json['displayName']?.toString() ??
          'Bé Yêu',
      targetAgeGroup: json['targetAgeGroup']?.toString() ?? '1',
      readingLevel: json['readingLevel']?.toString() ?? 'Cơ bản',
      dailyTimeLimit: dailyTime,
      remainingTimeLimit: remainingTime,
      dailyCharacterLimit: json['dailyCharacterLimit'] is int
          ? json['dailyCharacterLimit'] as int
          : int.tryParse(json['dailyCharacterLimit']?.toString() ?? '') ?? 5,
      remainingCharacterLimit: json['remainingCharacterLimit'] is int
          ? json['remainingCharacterLimit'] as int
          : int.tryParse(json['remainingCharacterLimit']?.toString() ?? '') ??
                5,
      avatarEmoji:
          json['avatarEmoji']?.toString() ??
          _defaultEmojiForName(json['nickName']?.toString()),
      avatarUrl: json['avatarUrl']?.toString() ??
          json['avatar']?.toString() ??
          json['photoUrl']?.toString(),
      stars: json['stars'] is int ? json['stars'] as int : 120,
      streakDays: json['streakDays'] is int ? json['streakDays'] as int : 3,
    );
  }

  /// Đường dẫn hình đại diện đồng bộ theo cài đặt của Phụ Huynh (FE / Parent settings)
  String get avatarAssetPath {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://')) {
        return avatarUrl!;
      }
      if (avatarUrl!.contains('seed')) return 'assets/images/seed.webp';
      if (avatarUrl!.contains('rabbit')) return 'assets/images/rabbit.webp';
      final match = RegExp(r'child-\d+').firstMatch(avatarUrl!);
      if (match != null) {
        return 'assets/images/child-avatars/${match.group(0)}.png';
      }
    }

    // Mapping theo tên bé được chọn ở màn đăng nhập hoặc cha mẹ đặt
    final lower = nickName.toLowerCase();
    if (lower.contains('bống') || lower.contains('đổng') || lower.contains('bong') || lower.contains('dong')) {
      return 'assets/images/child-avatars/child-01.png';
    }
    if (lower.contains('bo') || lower.contains('bơ') || lower.contains('bảo')) {
      return 'assets/images/child-avatars/child-02.png';
    }
    if (lower.contains('mimi') || lower.contains('mi mi') || lower.contains('mây') || lower.contains('may')) {
      return 'assets/images/child-avatars/child-03.png';
    }
    if (lower.contains('nắng') || lower.contains('nang') || lower.contains('thỏ')) {
      return 'assets/images/rabbit.webp';
    }

    // Thuật toán profileIndex xác định ảnh theo id giống hệt FE (ChildAvatar.jsx)
    final key = id.isNotEmpty ? id : nickName;
    if (key.isNotEmpty) {
      final sum = key.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
      final idx = (sum % 12) + 1;
      final padded = idx.toString().padLeft(2, '0');
      return 'assets/images/child-avatars/child-$padded.png';
    }

    return 'assets/images/child-avatars/child-01.png';
  }

  /// Whether the child has daily screen time remaining
  bool get hasRemainingTime => remainingTimeLimit > 0;

  /// Whether the child can create a new character today
  bool get canCreateCharacter => remainingCharacterLimit > 0;

  /// Convert to UpdateChildProfileDto for PUT /api/child-profiles/{id}
  Map<String, dynamic> toUpdateDto() {
    return {
      'nickName': nickName,
      'targetAgeGroup': targetAgeGroup,
      'readingLevel': readingLevel,
      'dailyTimeLimit': dailyTimeLimit,
      'remainingTimeLimit': remainingTimeLimit,
      'dailyCharacterLimit': dailyCharacterLimit,
      'remainingCharacterLimit': remainingCharacterLimit,
    };
  }

  /// Full JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickName,
      'targetAgeGroup': targetAgeGroup,
      'readingLevel': readingLevel,
      'dailyTimeLimit': dailyTimeLimit,
      'remainingTimeLimit': remainingTimeLimit,
      'dailyCharacterLimit': dailyCharacterLimit,
      'remainingCharacterLimit': remainingCharacterLimit,
      'avatarEmoji': avatarEmoji,
      'stars': stars,
      'streakDays': streakDays,
    };
  }

  ChildProfile copyWith({
    String? id,
    String? userId,
    String? nickName,
    String? targetAgeGroup,
    String? readingLevel,
    int? dailyTimeLimit,
    int? remainingTimeLimit,
    int? dailyCharacterLimit,
    int? remainingCharacterLimit,
    String? avatarEmoji,
    String? avatarUrl,
    int? stars,
    int? streakDays,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickName: nickName ?? this.nickName,
      targetAgeGroup: targetAgeGroup ?? this.targetAgeGroup,
      readingLevel: readingLevel ?? this.readingLevel,
      dailyTimeLimit: dailyTimeLimit ?? this.dailyTimeLimit,
      remainingTimeLimit: remainingTimeLimit ?? this.remainingTimeLimit,
      dailyCharacterLimit: dailyCharacterLimit ?? this.dailyCharacterLimit,
      remainingCharacterLimit:
          remainingCharacterLimit ?? this.remainingCharacterLimit,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stars: stars ?? this.stars,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  String get targetAgeGroupDisplayName {
    switch (targetAgeGroup.toString().trim()) {
      case '0':
      case '3-5':
        return '3 - 5 tuổi (Mầm non)';
      case '1':
      case '6-8':
        return '6 - 8 tuổi (Tiểu học)';
      case '2':
      case '9-12':
        return '9 - 12 tuổi (Khám phá)';
      default:
        return 'Nhóm $targetAgeGroup';
    }
  }

  /// Trả về số thứ tự nhóm tuổi tương ứng trong StoryTemplate (1: 3-5 tuổi, 2: 6-8 tuổi, 3: 9-12 tuổi)
  int get matchedStoryAgeGroup {
    final tag = targetAgeGroup.toString().trim().toLowerCase();
    // 0 / 3-5 / mầm non -> StoryTemplate ageGroup 1 (3-5 tuổi)
    if (tag == '0' ||
        tag == '3-5' ||
        tag.contains('mầm') ||
        tag == '3' ||
        tag == '4' ||
        tag == '5') {
      return 1;
    }
    // 2 / 9-12 / khám phá -> StoryTemplate ageGroup 3 (9-12 tuổi)
    if (tag == '2' ||
        tag == '9-12' ||
        tag.contains('khám') ||
        tag == '9' ||
        tag == '10' ||
        tag == '11' ||
        tag == '12') {
      return 3;
    }
    // 1 / 6-8 / tiểu học -> StoryTemplate ageGroup 2 (6-8 tuổi)
    if (tag == '1' ||
        tag == '6-8' ||
        tag.contains('tiểu') ||
        tag == '6' ||
        tag == '7' ||
        tag == '8') {
      return 2;
    }
    final parsed = int.tryParse(tag);
    if (parsed != null) {
      if (parsed == 0) return 1;
      if (parsed >= 1 && parsed <= 3) return parsed;
    }
    return 2; // Mặc định nhóm 2 (6-8 tuổi)
  }

  static String _defaultEmojiForName(String? name) {
    if (name == null) return '👶';
    final n = name.toLowerCase();
    if (n.contains('peppa') || n.contains('heo')) return '🐷';
    if (n.contains('gấu') || n.contains('pooh')) return '🐻';
    if (n.contains('thỏ') || n.contains('bunny')) return '🐰';
    if (n.contains('mèo') || n.contains('kitty')) return '🐱';
    if (n.contains('rồng') || n.contains('dragon')) return '🐲';
    if (n.contains('sư tử') || n.contains('leo')) return '🦁';
    return '👶';
  }
}
