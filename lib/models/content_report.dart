import 'backend_enums.dart';
export 'backend_enums.dart';

/// Represents a Content Safety Report from /api/content-reports (Luồng 8 & Child Safety)
class ContentReport {
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reason;
  final ContentReportStatus status;
  final String? createdAt;

  const ContentReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.status = ContentReportStatus.pending,
    this.createdAt,
  });

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    final targetVal = json['targetType'];
    ReportTargetType parsedTarget = ReportTargetType.story;
    if (targetVal is int) {
      parsedTarget = ReportTargetType.fromInt(targetVal);
    } else if (targetVal is String) {
      switch (targetVal.toLowerCase()) {
        case 'character':
          parsedTarget = ReportTargetType.character;
          break;
        case 'story':
        case 'storytemplate':
          parsedTarget = ReportTargetType.story;
          break;
        case 'content':
          parsedTarget = ReportTargetType.content;
          break;
      }
    }

    final statusVal = json['status'];
    ContentReportStatus parsedStatus = ContentReportStatus.pending;
    if (statusVal is int) {
      parsedStatus = ContentReportStatus.fromInt(statusVal);
    }

    return ContentReport(
      id: json['id']?.toString() ?? '',
      targetType: parsedTarget,
      targetId: json['targetId']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: parsedStatus,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetType': targetType.index,
      'targetId': targetId,
      'reason': reason,
      'status': status.index,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toCreateDto() {
    return {
      'targetType': targetType.index,
      'targetId': targetId,
      'reason': reason,
      'status': status.index,
    };
  }
}
