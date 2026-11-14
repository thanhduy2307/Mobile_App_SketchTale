import 'package:flutter/material.dart';
import '../utils/app_config.dart';
import 'vocabulary_template.dart';
import 'story_quiz_template.dart';
import 'story_role_template.dart';
import 'story_animation.dart';
export 'backend_enums.dart';
export 'child_profile.dart';
export 'vocabulary_template.dart';
export 'story_quiz_template.dart';
export 'story_role_template.dart';
export 'story_animation.dart';
export 'reading_log_quiz.dart';
export 'auth_models.dart';
export 'character_mapping.dart';
export 'char_type.dart';
export 'content_report.dart';
export 'credit_cost.dart';
export 'drawing_ai_models.dart';

/// Represents a stroke point drawn on the canvas
class DrawingPoint {
  final Offset offset;
  final Paint paint;

  const DrawingPoint({
    required this.offset,
    required this.paint,
  });
}

/// Represents a character drawn and animated by the kid
class KidCharacter {
  final String id;
  final String name;
  final String title;
  final String description;
  final String drawingUrl;
  final String avatar3dUrl;
  final bool isParentApproved;
  final String voicePhrase;
  final Color themeColor;
  final String? assignedRole; // e.g. "Hiệp Sĩ Rồng Con", "Dũng Sĩ", "Thỏ Trắng"
  final String personality; // "Dũng Sĩ", "Thú Cưng", "Phù Thủy"
  final DateTime createdAt;

  const KidCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.drawingUrl,
    required this.avatar3dUrl,
    required this.isParentApproved,
    required this.voicePhrase,
    required this.themeColor,
    this.assignedRole,
    this.personality = 'Dũng Sĩ',
    required this.createdAt,
  });

  /// Avatar URL (ưu tiên ảnh 3D, nếu chưa có thì dùng ảnh nét vẽ)
  String get avatarAsset => avatar3dUrl.isNotEmpty ? avatar3dUrl : drawingUrl;

  KidCharacter copyWith({
    String? name,
    String? title,
    String? description,
    String? drawingUrl,
    String? avatar3dUrl,
    bool? isParentApproved,
    String? voicePhrase,
    Color? themeColor,
    String? assignedRole,
    String? personality,
  }) {
    return KidCharacter(
      id: id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      drawingUrl: drawingUrl ?? this.drawingUrl,
      avatar3dUrl: avatar3dUrl ?? this.avatar3dUrl,
      isParentApproved: isParentApproved ?? this.isParentApproved,
      voicePhrase: voicePhrase ?? this.voicePhrase,
      themeColor: themeColor ?? this.themeColor,
      assignedRole: assignedRole ?? this.assignedRole,
      personality: personality ?? this.personality,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'drawingUrl': drawingUrl,
      'avatar3dUrl': avatar3dUrl,
      'isParentApproved': isParentApproved,
      'voicePhrase': voicePhrase,
      'themeColor': themeColor.toARGB32(),
      if (assignedRole != null) 'assignedRole': assignedRole,
      'personality': personality,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory KidCharacter.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'];
    final bool isApproved = statusVal == 2 ||
        statusVal == 'Approved' ||
        statusVal == 'approved' ||
        json['isParentApproved'] == true;

    final charId = json['characterId']?.toString() ??
        json['id']?.toString() ??
        '';
    final charName = json['characterName']?.toString() ??
        json['name']?.toString() ??
        'Bạn 3D';
    final pronoun = json['defaultPronoun']?.toString() ?? '';
    final prompt = json['aiPromptUsed']?.toString() ??
        json['description']?.toString() ??
        '';
    final rawAvatar = json['finalImageUrl']?.toString() ??
        json['avatar3dUrl']?.toString() ??
        '';
    final rawDrawing = json['originalDrawingUrl']?.toString() ??
        json['drawingUrl']?.toString() ??
        '';
    final avatar3dUrl = AppConfig.resolveImageUrl(rawAvatar);
    final drawingUrl = AppConfig.resolveImageUrl(rawDrawing);

    return KidCharacter(
      id: charId,
      name: charName,
      title: pronoun.isNotEmpty
          ? pronoun
          : (json['title']?.toString() ?? 'Nhân vật sáng tạo của bé'),
      description: prompt,
      drawingUrl: drawingUrl,
      avatar3dUrl: avatar3dUrl,
      isParentApproved: isApproved,
      voicePhrase: json['voicePhrase']?.toString() ??
          'Chào bé yêu, tớ là bạn $charName!',
      themeColor: json['themeColor'] != null
          ? Color((json['themeColor'] as num).toInt())
          : const Color(0xFFF59E0B),
      assignedRole: json['assignedRole']?.toString() ??
          (pronoun.isNotEmpty ? pronoun : null),
      personality: pronoun.isNotEmpty
          ? pronoun
          : (json['personality']?.toString() ?? 'Dũng Sĩ'),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// A vocabulary highlight inside a story
class VocabItem {
  final String word;
  final String phonetic;
  final String definition;
  final String iconName;

  const VocabItem({
    required this.word,
    required this.phonetic,
    required this.definition,
    this.iconName = 'shield',
  });
}

/// Represents a Character Slot Template on a Story Page (/api/story-pages/{pageId}/slots)
/// Coordinates `posX` and `posY` are stage percentages (0..100) matching Content Manager Studio.
class CharacterSlotTemplate {
  final String id;
  final String storyPageId;
  final String? storyRoleTemplateId;
  final double posX;
  final double posY;
  final double scale;
  final double rotation;
  final int layer;
  final String anchor;
  final String? assetUrl;
  final bool flipHorizontal;
  final int status;
  final List<StoryAnimationClip> animationClips;

  const CharacterSlotTemplate({
    required this.id,
    required this.storyPageId,
    this.storyRoleTemplateId,
    this.posX = 40.0,
    this.posY = 80.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.layer = 1,
    this.anchor = 'center',
    this.assetUrl,
    this.flipHorizontal = false,
    this.status = 1,
    this.animationClips = const [],
  });

  String get fullAssetUrl => AppConfig.resolveImageUrl(assetUrl);

  factory CharacterSlotTemplate.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val, double fallback) {
      if (val is num) return val.toDouble();
      if (val != null) return double.tryParse(val.toString()) ?? fallback;
      return fallback;
    }

    final rawX = json['posX'] ?? json['PosX'] ?? json['x'];
    final rawY = json['posY'] ?? json['PosY'] ?? json['y'];
    final rawScale = json['scale'] ?? json['Scale'];
    final rawRotation = json['rotation'] ?? json['Rotation'];
    final rawLayer = json['layer'] ?? json['Layer'];
    final rawFlip = json['flipHorizontal'] ?? json['FlipHorizontal'] ?? json['flip'];

    return CharacterSlotTemplate(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      storyPageId: (json['storyPageId'] ?? json['StoryPageId'] ?? json['pageId'] ?? '').toString(),
      storyRoleTemplateId: (json['storyRoleTemplateId'] ?? json['StoryRoleTemplateId'] ?? json['roleId'])?.toString(),
      posX: parseNum(rawX, 40.0),
      posY: parseNum(rawY, 80.0),
      scale: parseNum(rawScale, 1.0),
      rotation: parseNum(rawRotation, 0.0),
      layer: rawLayer is int ? rawLayer : int.tryParse(rawLayer?.toString() ?? '') ?? 1,
      anchor: (json['anchor'] ?? json['Anchor'] ?? 'center').toString(),
      assetUrl: (json['assetUrl'] ?? json['AssetUrl'])?.toString(),
      flipHorizontal: rawFlip == true || rawFlip?.toString() == 'true',
      status: json['status'] is int ? json['status'] as int : 1,
      animationClips: StoryAnimationClip.parsePageClips(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyPageId': storyPageId,
      if (storyRoleTemplateId != null) 'storyRoleTemplateId': storyRoleTemplateId,
      'posX': posX,
      'posY': posY,
      'scale': scale,
      if (rotation != 0.0) 'rotation': rotation,
      if (layer != 1) 'layer': layer,
      if (anchor != 'center') 'anchor': anchor,
      if (assetUrl != null) 'assetUrl': assetUrl,
      'flipHorizontal': flipHorizontal,
      'status': status,
      if (animationClips.isNotEmpty)
        'animationClips': animationClips.map((c) => c.toJson()).toList(),
    };
  }

  CharacterSlotTemplate copyWith({
    String? id,
    String? storyPageId,
    String? storyRoleTemplateId,
    double? posX,
    double? posY,
    double? scale,
    double? rotation,
    int? layer,
    String? anchor,
    String? assetUrl,
    bool? flipHorizontal,
    int? status,
    List<StoryAnimationClip>? animationClips,
  }) {
    return CharacterSlotTemplate(
      id: id ?? this.id,
      storyPageId: storyPageId ?? this.storyPageId,
      storyRoleTemplateId: storyRoleTemplateId ?? this.storyRoleTemplateId,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      layer: layer ?? this.layer,
      anchor: anchor ?? this.anchor,
      assetUrl: assetUrl ?? this.assetUrl,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      status: status ?? this.status,
      animationClips: animationClips ?? this.animationClips,
    );
  }
}

/// A single story page
class StoryPage {
  final String? id; // Backend page UUID
  final int pageNumber;
  final String imageUrl;
  final String textContent;
  final String? englishSubtitle;
  final String chapterTitle;
  final VocabItem? vocab;
  final String narratorName;
  final String? audioNarrationUrl;
  final String? characterAction; // e.g. 'sleep', 'patrol', 'dance', 'fly', 'stomp', 'idle'
  final String? characterSpeech; // Lời thoại theo ngữ cảnh trang của nhân vật
  final List<CharacterSlotTemplate> slots;
  final List<StoryAnimationClip> animationClips;
  final List<VocabularyTemplate> vocabularies;

  const StoryPage({
    this.id,
    required this.pageNumber,
    required this.imageUrl,
    required this.textContent,
    this.englishSubtitle,
    this.chapterTitle = 'Chương 2: Chìa Khóa Ánh Sáng',
    this.vocab,
    this.narratorName = 'Chú Gấu Pô',
    this.audioNarrationUrl,
    this.characterAction,
    this.characterSpeech,
    this.slots = const [],
    this.animationClips = const [],
    this.vocabularies = const [],
  });

  StoryPage copyWith({
    String? id,
    int? pageNumber,
    String? imageUrl,
    String? textContent,
    String? englishSubtitle,
    String? chapterTitle,
    VocabItem? vocab,
    String? narratorName,
    String? audioNarrationUrl,
    String? characterAction,
    String? characterSpeech,
    List<CharacterSlotTemplate>? slots,
    List<StoryAnimationClip>? animationClips,
    List<VocabularyTemplate>? vocabularies,
  }) {
    return StoryPage(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      textContent: textContent ?? this.textContent,
      englishSubtitle: englishSubtitle ?? this.englishSubtitle,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      vocab: vocab ?? this.vocab,
      narratorName: narratorName ?? this.narratorName,
      audioNarrationUrl: audioNarrationUrl ?? this.audioNarrationUrl,
      characterAction: characterAction ?? this.characterAction,
      characterSpeech: characterSpeech ?? this.characterSpeech,
      slots: slots ?? this.slots,
      animationClips: animationClips ?? this.animationClips,
      vocabularies: vocabularies ?? this.vocabularies,
    );
  }
}

/// Quiz Option details
class QuizOptionDetail {
  final String letter; // 'A', 'B', 'C', 'D'
  final String title;
  final String subtitle;
  final String imageUrl;

  const QuizOptionDetail({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

/// Quiz Question after completing a chapter
class QuizQuestion {
  final String questionText;
  final String visualClueUrl;
  final List<String> options;
  final List<String> optionEmojis;
  final List<QuizOptionDetail> optionDetails;
  final int correctIndex;
  final String celebrationTitle;
  final String celebrationMessage;
  final int rewardStars;
  final String hint;

  const QuizQuestion({
    required this.questionText,
    required this.visualClueUrl,
    required this.options,
    required this.optionEmojis,
    this.optionDetails = const [],
    required this.correctIndex,
    required this.celebrationTitle,
    required this.celebrationMessage,
    this.rewardStars = 10,
    this.hint = 'Bé hãy nhớ lại lúc bạn Rồng bước vào hang đá tối nhé!',
  });

  String get hintText => hint;
  String get explanation => celebrationMessage;
}

/// Interactive Kid Story
class Story {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;
  final String ageRange;
  final String category;
  final int totalPages;
  final int currentPage;
  final bool isCompleted;
  final int durationMinutes;
  final double rating;
  final String narrator;
  final String characterName;
  final List<StoryPage> pages;
  final QuizQuestion quiz;
  final List<StoryQuizTemplate> quizTemplates;
  final List<StoryRoleTemplate> roles;
  final String heroRoleTitle;
  final String companionRoleTitle;

  const Story({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.ageRange,
    required this.category,
    required this.totalPages,
    required this.currentPage,
    required this.isCompleted,
    this.durationMinutes = 6,
    this.rating = 5.0,
    this.narrator = 'Chú Gấu Pô',
    this.characterName = 'Rồng Con',
    required this.pages,
    required this.quiz,
    this.quizTemplates = const [],
    this.roles = const [],
    this.heroRoleTitle = 'Hiệp Sĩ Rồng Con',
    this.companionRoleTitle = 'Chú Gấu Pô',
  });

  /// All playable quizzes for this story
  List<QuizQuestion> get allQuizzes => quizTemplates.isNotEmpty
      ? quizTemplates.map((q) => q.toQuizQuestion()).toList()
      : [quiz];

  Story copyWith({
    int? currentPage,
    bool? isCompleted,
    QuizQuestion? quiz,
    List<StoryQuizTemplate>? quizTemplates,
    List<StoryRoleTemplate>? roles,
  }) {
    return Story(
      id: id,
      title: title,
      subtitle: subtitle,
      coverUrl: coverUrl,
      ageRange: ageRange,
      category: category,
      totalPages: totalPages,
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      durationMinutes: durationMinutes,
      rating: rating,
      narrator: narrator,
      characterName: characterName,
      pages: pages,
      quiz: quiz ?? this.quiz,
      quizTemplates: quizTemplates ?? this.quizTemplates,
      roles: roles ?? this.roles,
      heroRoleTitle: heroRoleTitle,
      companionRoleTitle: companionRoleTitle,
    );
  }
}

/// Represents an Education Theme from /api/education-themes
class EducationTheme {
  final String id;
  final String name;
  final String description;
  final int? status;
  final String? createdAt;

  const EducationTheme({
    required this.id,
    required this.name,
    required this.description,
    this.status,
    this.createdAt,
  });

  factory EducationTheme.fromJson(Map<String, dynamic> json) {
    final viName = json['nameVi']?.toString() ?? json['NameVi']?.toString();
    final enName = json['nameEn']?.toString() ?? json['NameEn']?.toString();
    final fallbackName = json['name']?.toString() ?? json['Name']?.toString() ?? 'Chủ đề';
    final resolvedName = (viName != null && viName.isNotEmpty)
        ? viName
        : ((enName != null && enName.isNotEmpty) ? enName : fallbackName);

    return EducationTheme(
      id: json['id'] as String? ?? json['Id'] as String? ?? '',
      name: resolvedName,
      description: json['description'] as String? ?? json['Description'] as String? ?? '',
      status: json['status'] as int? ?? json['Status'] as int?,
      createdAt: json['createdAt'] as String? ?? json['CreatedAt'] as String?,
    );
  }

  String get emoji => '';

  String get displayName => name;
}

/// Represents a single Page in a Story Template from /api/story-template-page/{id}
class StoryTemplatePage {
  final String id;
  final String storyTemplateId;
  final int pageNumber;
  final String imageUrl;
  final String rawText;
  final String? audioNarrationUrl;
  final List<CharacterSlotTemplate> slots;
  final List<StoryAnimationClip> animationClips;

  const StoryTemplatePage({
    required this.id,
    required this.storyTemplateId,
    required this.pageNumber,
    required this.imageUrl,
    required this.rawText,
    this.audioNarrationUrl,
    this.slots = const [],
    this.animationClips = const [],
  });

  factory StoryTemplatePage.fromJson(Map<String, dynamic> json) {
    final rawBg = json['backgroundUrl'] ??
        json['BackgroundUrl'] ??
        json['imageUrl'] ??
        json['ImageUrl'] ??
        json['image_url'] ??
        '';
    final rawTextVal = json['rawText'] ??
        json['RawText'] ??
        json['text'] ??
        json['content'] ??
        '';
    final pageNumVal = json['pageNumber'] ??
        json['PageNumber'] ??
        json['page_number'] ??
        1;
    final audioVal = json['audioNarrationUrl'] ??
        json['AudioNarrationUrl'] ??
        json['audio_url'];
    final idVal = json['id'] ?? json['Id'] ?? '';
    final storyIdVal = json['storyTemplateId'] ??
        json['StoryTemplateId'] ??
        json['story_template_id'] ??
        '';

    final rawSlots = json['slots'] ?? json['Slots'];
    final parsedSlots = rawSlots is List
        ? rawSlots
            .whereType<Map>()
            .map((s) => CharacterSlotTemplate.fromJson(Map<String, dynamic>.from(s)))
            .toList()
        : const <CharacterSlotTemplate>[];

    return StoryTemplatePage(
      id: idVal.toString(),
      storyTemplateId: storyIdVal.toString(),
      pageNumber: (pageNumVal is num)
          ? pageNumVal.toInt()
          : int.tryParse(pageNumVal.toString()) ?? 1,
      imageUrl: rawBg.toString(),
      rawText: rawTextVal.toString(),
      audioNarrationUrl: audioVal?.toString(),
      slots: parsedSlots,
      animationClips: StoryAnimationClip.parsePageClips(json),
    );
  }

  String get fullImageUrl => AppConfig.resolveImageUrl(imageUrl);
}

/// Represents a Story Template from /api/story-template/getallstories
class StoryTemplate {
  final String id;
  final String educationThemeId;
  final String title;
  final String description;
  final int ageGroup;
  final String coverImageUrl;
  final int totalPageNumbers;
  final int status;
  final String? createdAt;
  final EducationTheme? educationTheme;
  final List<StoryTemplatePage> pages;

  const StoryTemplate({
    required this.id,
    required this.educationThemeId,
    required this.title,
    required this.description,
    required this.ageGroup,
    required this.coverImageUrl,
    required this.totalPageNumbers,
    required this.status,
    this.createdAt,
    this.educationTheme,
    this.pages = const [],
  });

  factory StoryTemplate.fromJson(
    Map<String, dynamic> json, {
    Map<String, EducationTheme>? themesMap,
    List<StoryTemplatePage>? pages,
  }) {
    final themeId = json['educationThemeId'] as String? ?? '';
    final theme = themesMap != null ? themesMap[themeId] : null;

    return StoryTemplate(
      id: json['id'] as String? ?? '',
      educationThemeId: themeId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ageGroup: json['ageGroup'] as int? ?? 1,
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      totalPageNumbers: json['totalPageNumbers'] as int? ?? 2,
      status: json['status'] as int? ?? 2,
      createdAt: json['createdAt'] as String?,
      educationTheme: theme,
      pages: pages ?? const [],
    );
  }

  StoryTemplate copyWith({
    EducationTheme? educationTheme,
    List<StoryTemplatePage>? pages,
  }) {
    return StoryTemplate(
      id: id,
      educationThemeId: educationThemeId,
      title: title,
      description: description,
      ageGroup: ageGroup,
      coverImageUrl: coverImageUrl,
      totalPageNumbers: totalPageNumbers,
      status: status,
      createdAt: createdAt,
      educationTheme: educationTheme ?? this.educationTheme,
      pages: pages ?? this.pages,
    );
  }

  String get fullCoverUrl => AppConfig.resolveImageUrl(coverImageUrl);

  String get ageGroupTitle {
    switch (ageGroup) {
      case 1:
        return '3 - 5 tuổi';
      case 2:
        return '6 - 8 tuổi';
      case 3:
        return '9 - 12 tuổi';
      default:
        return 'Nhóm $ageGroup';
    }
  }

  String get ageGroupBadge {
    switch (ageGroup) {
      case 1:
        return '3-5 tuổi (Nhóm 1)';
      case 2:
        return '6-8 tuổi (Nhóm 2)';
      case 3:
        return '9-12 tuổi (Nhóm 3)';
      default:
        return 'Nhóm $ageGroup';
    }
  }

  /// Converts this API StoryTemplate into a full interactive Story model
  Story toStory() {
    final themeName = educationTheme?.displayName ?? 'Khám Phá';
    final List<StoryPage> storyPages;
    if (pages.isNotEmpty) {
      storyPages = pages.map((p) {
        return StoryPage(
          id: p.id,
          pageNumber: p.pageNumber,
          imageUrl: p.fullImageUrl,
          textContent: p.rawText,
          englishSubtitle: p.rawText,
          chapterTitle: 'Trang ${p.pageNumber}: $title',
          narratorName: 'Chú Gấu Pô',
          audioNarrationUrl: p.audioNarrationUrl,
          slots: p.slots,
          animationClips: p.animationClips,
        );
      }).toList();
      storyPages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    } else if (id == '21a89526-20b1-471b-bce0-bc23c4fb7418' || title.toLowerCase().contains('bobby')) {
      storyPages = [
        StoryPage(
          id: 'b9e0a450-f357-48b5-a27d-b31ce11df38d',
          pageNumber: 1,
          imageUrl: fullCoverUrl,
          textContent: 'Bobby và những người bạn bước vào khu vườn kỳ diệu...',
          englishSubtitle: 'Bobby steps into the magical garden...',
          chapterTitle: 'Trang 1: $title',
          narratorName: 'Chú Gấu Pô',
          slots: const [
            CharacterSlotTemplate(
              id: 'bobby-slot-1',
              storyPageId: 'b9e0a450-f357-48b5-a27d-b31ce11df38d',
              posX: 67.0,
              posY: 60.0,
              scale: 1.05,
            ),
          ],
        ),
        StoryPage(
          id: 'p2-$id',
          pageNumber: 2,
          imageUrl: fullCoverUrl,
          textContent: 'Bobby cùng bạn nhỏ tưới nước cho mầm cây xinh xắn...',
          englishSubtitle: 'Bobby waters the lovely seedling...',
          chapterTitle: 'Trang 2: $title',
          narratorName: 'Chú Gấu Pô',
        ),
        StoryPage(
          id: '8151605a-1d43-4d7b-9a51-71abd97f04f0',
          pageNumber: 3,
          imageUrl: fullCoverUrl,
          textContent: 'Bobby nhìn thấy những bông hoa rực rỡ hé nở...',
          englishSubtitle: 'Bobby sees the colorful flowers blooming...',
          chapterTitle: 'Trang 3: $title',
          narratorName: 'Chú Gấu Pô',
        ),
        StoryPage(
          id: '782a765f-c333-417b-8b41-0addce91ff07',
          pageNumber: 4,
          imageUrl: fullCoverUrl,
          textContent: 'Bobby nhận ra món quà quý giá chính là tình yêu thiên nhiên...',
          englishSubtitle: 'Bobby realizes the gift is love for nature...',
          chapterTitle: 'Trang 4: $title',
          narratorName: 'Chú Gấu Pô',
        ),
        StoryPage(
          id: 'p5-$id',
          pageNumber: 5,
          imageUrl: fullCoverUrl,
          textContent: 'Bobby mỉm cười và chia sẻ niềm vui cùng bạn bè...',
          englishSubtitle: 'Bobby smiles and shares joy with friends...',
          chapterTitle: 'Trang 5: $title',
          narratorName: 'Chú Gấu Pô',
        ),
      ];
    } else {
      final total = (totalPageNumbers > 0) ? totalPageNumbers : 3;
      storyPages = List.generate(total, (i) {
        final pageNum = i + 1;
        return StoryPage(
          id: '$id-fallback-page-$pageNum',
          pageNumber: pageNum,
          imageUrl: fullCoverUrl,
          textContent: 'Trang $pageNum: Câu chuyện $title đang mở ra hành trình kỳ diệu dành cho bé.',
          englishSubtitle: 'Page $pageNum: A wonderful journey begins for you.',
          chapterTitle: 'Trang $pageNum: $title',
          narratorName: 'Chú Gấu Pô',
        );
      });
    }

    return Story(
      id: id,
      title: title,
      subtitle: description,
      coverUrl: fullCoverUrl,
      ageRange: ageGroupTitle,
      category: themeName,
      totalPages: (totalPageNumbers > 0)
          ? totalPageNumbers
          : (storyPages.isNotEmpty ? storyPages.length : 3),
      currentPage: 1,
      isCompleted: false,
      durationMinutes: (storyPages.length * 2).clamp(3, 15),
      rating: 5.0,
      narrator: 'Chú Gấu Pô',
      characterName: title,
      heroRoleTitle: 'Nhân vật chính',
      companionRoleTitle: 'Bạn đồng hành',
      pages: storyPages,
      quiz: QuizQuestion(
        questionText: 'Câu chuyện "$title" đã mang lại bài học quý giá gì cho bé nhỉ?',
        visualClueUrl: fullCoverUrl,
        options: [
          'A. Tinh thần ${educationTheme?.name ?? "học hỏi"} & yêu thương',
          'B. Luôn vui vẻ và lạc quan',
          'C. Cùng nhau chia sẻ điều tốt lành',
          'D. Cả 3 điều trên đều đúng!',
        ],
        optionEmojis: ['', '', '', ''],
        optionDetails: [
          QuizOptionDetail(letter: 'A', title: 'A. Tinh thần ${educationTheme?.name ?? "học hỏi"}', subtitle: 'Học hỏi điều mới', imageUrl: fullCoverUrl),
          QuizOptionDetail(letter: 'B', title: 'B. Luôn vui vẻ', subtitle: 'Lạc quan yêu đời', imageUrl: fullCoverUrl),
          QuizOptionDetail(letter: 'C', title: 'C. Chia sẻ', subtitle: 'Yêu thương bạn bè', imageUrl: fullCoverUrl),
          QuizOptionDetail(letter: 'D', title: 'D. Cả 3 điều trên', subtitle: 'Đúng nhất luôn!', imageUrl: fullCoverUrl),
        ],
        correctIndex: 3,
        celebrationTitle: 'Bé Giỏi Lắm!',
        celebrationMessage: 'Bé đã hoàn thành câu chuyện $title và ghi nhớ thông điệp thật tuyệt vời!',
        rewardStars: 10,
      ),
      quizTemplates: const [],
      roles: const [],
    );
  }
}

