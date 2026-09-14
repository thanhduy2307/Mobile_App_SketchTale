import 'package:flutter/material.dart';

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
  final String? assignedRole; // e.g. "Dũng Sĩ Rừng Xanh", "Thỏ Trắng"
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
    required this.createdAt,
  });

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
      createdAt: createdAt,
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

/// A single story page
class StoryPage {
  final int pageNumber;
  final String imageUrl;
  final String textContent;
  final VocabItem? vocab;
  final String narratorName;

  const StoryPage({
    required this.pageNumber,
    required this.imageUrl,
    required this.textContent,
    this.vocab,
    this.narratorName = 'Cô Ban Mai',
  });
}

/// Quiz Question after completing a chapter
class QuizQuestion {
  final String questionText;
  final String visualClueUrl;
  final List<String> options;
  final List<String> optionEmojis;
  final int correctIndex;
  final String celebrationTitle;
  final String celebrationMessage;
  final int rewardStars;

  const QuizQuestion({
    required this.questionText,
    required this.visualClueUrl,
    required this.options,
    required this.optionEmojis,
    required this.correctIndex,
    required this.celebrationTitle,
    required this.celebrationMessage,
    this.rewardStars = 5,
  });
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
  final List<StoryPage> pages;
  final QuizQuestion quiz;
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
    required this.pages,
    required this.quiz,
    this.heroRoleTitle = 'Dũng Sĩ Rừng Xanh 🦁',
    this.companionRoleTitle = 'Thỏ Trắng Tinh Nghịch 🐰',
  });

  Story copyWith({
    int? currentPage,
    bool? isCompleted,
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
      pages: pages,
      quiz: quiz,
      heroRoleTitle: heroRoleTitle,
      companionRoleTitle: companionRoleTitle,
    );
  }
}
