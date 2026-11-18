import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/drawing_ai_models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_loading.dart';
import '../drawing_styles.dart';

/// Pop-up xem truoc ban 3D, doi ten va bam xac nhan gui cho Ba Me phe duyet
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
              // 1. Nut Dong o goc tren ben phai
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.outline),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Đóng',
                ),
              ),
              const SizedBox(height: 4),

              // 2. 3D Mascot Preview Image
              Container(
                width: double.infinity,
                height: 185,
                decoration: DrawingStyles.mascotPreviewBoxDecoration,
                child: Center(
                  child: ClipRRect(
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

