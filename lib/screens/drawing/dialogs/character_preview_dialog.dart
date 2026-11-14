import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/drawing_ai_models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../drawing_styles.dart';

/// 🎭 Pop-up xem trước bạn 3D, nghe giọng, đổi tên và bấm xác nhận gửi cho Ba Mẹ phê duyệt
class CharacterPreviewDialog extends StatefulWidget {
  final GenerateCharacterResponse genResponse;
  final String originalDrawingUrl;
  final String selectedTypeName;
  final int parentCredits;
  final VoidCallback onRetry;
  final VoidCallback onRegenerate;
  final Future<void> Function(String finalName) onConfirmAndSubmit;
  final VoidCallback onPlayVoice;

  const CharacterPreviewDialog({
    super.key,
    required this.genResponse,
    required this.originalDrawingUrl,
    required this.selectedTypeName,
    required this.parentCredits,
    required this.onRetry,
    required this.onRegenerate,
    required this.onConfirmAndSubmit,
    required this.onPlayVoice,
  });

  static Future<void> show(
    BuildContext context, {
    required GenerateCharacterResponse genResponse,
    required String originalDrawingUrl,
    required String selectedTypeName,
    required int parentCredits,
    required VoidCallback onRetry,
    required VoidCallback onRegenerate,
    required Future<void> Function(String finalName) onConfirmAndSubmit,
    required VoidCallback onPlayVoice,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CharacterPreviewDialog(
        genResponse: genResponse,
        originalDrawingUrl: originalDrawingUrl,
        selectedTypeName: selectedTypeName,
        parentCredits: parentCredits,
        onRetry: onRetry,
        onRegenerate: onRegenerate,
        onConfirmAndSubmit: onConfirmAndSubmit,
        onPlayVoice: onPlayVoice,
      ),
    );
  }

  @override
  State<CharacterPreviewDialog> createState() => _CharacterPreviewDialogState();
}

class _CharacterPreviewDialogState extends State<CharacterPreviewDialog> {
  late final TextEditingController _nameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final randomName = DrawingStyles.suggestedNames[
        Random().nextInt(DrawingStyles.suggestedNames.length)];
    _nameController = TextEditingController(text: randomName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 390,
        padding: DrawingStyles.dialogPadding,
        decoration: DrawingStyles.dialogCardDecoration,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top bar: Pill badge & Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: DrawingStyles.topPillBadgeDecoration,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.onPrimaryFixed,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bạn 3D Của Bé Đã Xuất Hiện!',
                          style: AppTypography.labelMd(color: AppColors.onPrimaryFixed),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.outline),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 2. Status & Credit Balance Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: DrawingStyles.pendingBadgeDecoration,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          size: 12,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Trạng thái: Chờ bé xác nhận',
                          style: DrawingStyles.pendingBadgeText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. 3D Mascot Preview Image
              Container(
                width: double.infinity,
                height: 185,
                decoration: DrawingStyles.mascotPreviewBoxDecoration,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: widget.genResponse.generateImageUrl.isNotEmpty
                          ? Image.network(
                              widget.genResponse.generateImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: appImageLoadingBuilder,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_rounded,
                                size: 70,
                                color: AppColors.primaryContainer,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported_rounded,
                              size: 70,
                              color: AppColors.primaryContainer,
                            ),
                    ),
                    // Voice Button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onPlayVoice,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: DrawingStyles.voiceBtnDecoration,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text('Nghe giọng', style: DrawingStyles.voiceBtnText),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Name Input with Dice Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: AppTypography.headlineSm(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Tên của bạn 3D',
                        labelStyle: AppTypography.labelSm(color: AppColors.primary),
                        prefixIcon: const Icon(
                          Icons.badge_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _nameController.text = DrawingStyles.suggestedNames[
                            Random().nextInt(DrawingStyles.suggestedNames.length)];
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Center(
                        child: Icon(Icons.casino_rounded, size: 20, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Actions: Vẽ lại | Tạo lại | Gửi Ba Mẹ Duyệt
              Row(
                children: [
                  // Retry (Hủy preview)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : widget.onRetry,
                      style: DrawingStyles.outlineRoundedBtn,
                      child: const Text('Vẽ Lại', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Regenerate (-50 credits)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : widget.onRegenerate,
                      style: DrawingStyles.regenerateBtn,
                      child: const Text(
                        'Tạo Lại',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Submit to Parent (Bé xác nhận)
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              final defaultName =
                                  (widget.selectedTypeName.isNotEmpty && widget.selectedTypeName != 'Khác')
                                      ? widget.selectedTypeName
                                      : 'Bạn 3D Diệu Kỳ';
                              final finalName = _nameController.text.trim().isEmpty
                                  ? defaultName
                                  : _nameController.text.trim();

                              try {
                                await widget.onConfirmAndSubmit(finalName);
                              } finally {
                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                }
                              }
                            },
                      style: DrawingStyles.primaryRoundedBtn,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Gửi Ba Mẹ Duyệt',
                              style: AppTypography.labelMd(color: AppColors.onPrimary),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

