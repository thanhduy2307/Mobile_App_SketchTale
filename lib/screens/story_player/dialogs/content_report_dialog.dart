import 'package:flutter/material.dart';
import '../../../models/backend_enums.dart';
import '../../../models/content_report.dart';
import '../../../services/content_report_service.dart';
import '../../../theme/app_theme.dart';
import '../story_player_styles.dart';

/// 🛡️ Dialog Báo Cáo Nội Dung Truyện (Safety Shield)
class ContentReportDialog extends StatefulWidget {
  final String storyId;
  final String? token;
  final void Function(String msg) onShowToast;

  const ContentReportDialog({
    super.key,
    required this.storyId,
    required this.token,
    required this.onShowToast,
  });

  static Future<void> show(
    BuildContext context, {
    required String storyId,
    required String? token,
    required void Function(String msg) onShowToast,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ContentReportDialog(
        storyId: storyId,
        token: token,
        onShowToast: onShowToast,
      ),
    );
  }

  @override
  State<ContentReportDialog> createState() => _ContentReportDialogState();
}

class _ContentReportDialogState extends State<ContentReportDialog> {
  static const _reasons = [
    'Hình ảnh làm bé sợ hãi',
    'Từ ngữ không phù hợp với lứa tuổi',
    'Nội dung sai thông tin',
    'Lý do khác...',
  ];

  String _selectedReason = _reasons.first;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: StoryPlayerStyles.reportDialogDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Báo Cáo An Toàn',
                        style: AppTypography.headlineSm(
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Bảo vệ trải nghiệm đọc cho bé',
                        style: AppTypography.bodySm(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bé hoặc bố mẹ cảm thấy điều gì không ổn ở trang này?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final reason in _reasons)
              GestureDetector(
                onTap: () => setState(() => _selectedReason = reason),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedReason == reason
                        ? const Color(0xFFFFEBEE)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedReason == reason
                          ? AppColors.error
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedReason == reason
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: _selectedReason == reason
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedReason == reason
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedReason == reason
                                ? AppColors.error
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSending
                        ? null
                        : () async {
                            setState(() => _isSending = true);
                            final nav = Navigator.of(context);
                            final res = await ContentReportService.reportContent(
                              targetType: ReportTargetType.story,
                              targetId: widget.storyId,
                              reason: _selectedReason,
                              token: widget.token,
                            );
                            nav.pop();
                            widget.onShowToast(res.message);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isSending ? 'Đang gửi...' : 'Gửi Báo Cáo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

