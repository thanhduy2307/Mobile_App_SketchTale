import 'backend_enums.dart';

/// Represents a Character Type from /api/char-types (Used in Workflow 3 AI classification & fallback)
class CharType {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameVi;
  final String? description;
  final CommonStatus status;
  final String? imageUrl;
  final String? createdAt;

  const CharType({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameVi,
    this.description,
    this.status = CommonStatus.active,
    this.imageUrl,
    this.createdAt,
  });

  factory CharType.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'];
    CommonStatus parsedStatus = CommonStatus.active;
    if (statusVal is int) {
      parsedStatus = CommonStatus.fromInt(statusVal);
    }

    final nVi = json['nameVi']?.toString() ?? json['NameVi']?.toString();
    final nEn = json['nameEn']?.toString() ?? json['NameEn']?.toString();
    final fallbackName = json['name']?.toString() ?? json['Name']?.toString() ?? '';
    final resolvedName = (nVi != null && nVi.trim().isNotEmpty)
        ? nVi.trim()
        : (nEn != null && nEn.trim().isNotEmpty ? nEn.trim() : fallbackName);

    return CharType(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',
      name: resolvedName,
      nameEn: nEn,
      nameVi: nVi,
      description: json['description']?.toString() ?? json['Description']?.toString(),
      status: parsedStatus,
      imageUrl: json['imageUrl']?.toString() ?? json['ImageUrl']?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['CreatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (nameEn != null) 'nameEn': nameEn,
      if (nameVi != null) 'nameVi': nameVi,
      if (description != null) 'description': description,
      'status': status.index,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  String get emoji {
    final n = '$name $nameEn $nameVi'.toLowerCase();
    if (n.contains('rồng') || n.contains('dragon')) return '🐲';
    if (n.contains('khủng long') || n.contains('dino')) return '🦖';
    if (n.contains('mèo') || n.contains('cat')) return '🐱';
    if (n.contains('chó') || n.contains('dog')) return '🐶';
    if (n.contains('thỏ') || n.contains('rabbit') || n.contains('bunny')) return '🐰';
    if (n.contains('gấu') || n.contains('bear')) return '🐻';
    if (n.contains('hổ') || n.contains('tiger')) return '🐯';
    if (n.contains('sư tử') || n.contains('lion')) return '🦁';
    if (n.contains('chim') || n.contains('bird')) return '🐦';
    if (n.contains('cá') || n.contains('fish')) return '🐟';
    if (n.contains('dũng sĩ') || n.contains('hero') || n.contains('hiệp sĩ') || n.contains('knight')) return '⚔️';
    if (n.contains('thú cưng') || n.contains('pet') || n.contains('động vật')) return '🐾';
    if (n.contains('phù thủy') || n.contains('wizard') || n.contains('phép thuật') || n.contains('magic')) return '🧙';
    if (n.contains('robot')) return '🤖';
    if (n.contains('bạn nhỏ') || n.contains('kid')) return '🧒';
    if (n.contains('tiên') || n.contains('fairy')) return '🧚';
    return '🌟';
  }
}
