import 'package:flutter/material.dart';
import '../../../models/drawing_ai_models.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../drawing_styles.dart';

/// 🤔 Dialog Giai đoạn 1 Dự phòng: Khi AI chưa nhận diện được rõ nét vẽ
/// Cho bé chọn cách 1 (Vẽ lại nét rõ hơn) hoặc cách 2 (Nói/Gõ ý tưởng + tự chọn loại nhân vật).
class AiFallbackDialog extends StatefulWidget {
  final AnalyzeDrawingResponse analyzeData;
  final List<CharType> availableCharTypes;
  final void Function({
    required String drawingId,
    required String originalImageUrl,
    required String charTypeId,
    required String charTypeName,
    String? standardizedPrompt,
    String? childAdditionalIdea,
    List<String>? detectedTags,
    bool isRegenerate,
  }) onGenerate;
  final VoidCallback onRedraw;
  final void Function(String msg)? onShowToast;

  const AiFallbackDialog({
    super.key,
    required this.analyzeData,
    required this.availableCharTypes,
    required this.onGenerate,
    required this.onRedraw,
    this.onShowToast,
  });

  @override
  State<AiFallbackDialog> createState() => _AiFallbackDialogState();
}

class _AiFallbackDialogState extends State<AiFallbackDialog> {
  late final TextEditingController _ideaController;
  late String _selectedCharTypeId;
  late String _selectedCharTypeName;

  @override
  void initState() {
    super.initState();
    _ideaController = TextEditingController();

    if (widget.availableCharTypes.isNotEmpty) {
      _selectedCharTypeId = widget.availableCharTypes.first.id;
      _selectedCharTypeName = widget.availableCharTypes.first.name;
    } else {
      _selectedCharTypeId = '';
      _selectedCharTypeName = '';
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: DrawingStyles.dialogPadding,
        decoration: DrawingStyles.dialogCardDecoration,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fallback Title Badge & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: DrawingStyles.pendingBadgeDecoration,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFFB45309),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Bút Thần Chưa Nhìn Rõ Nét Vẽ Này Rùi',
                          style: DrawingStyles.pendingBadgeText,
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
              const SizedBox(height: 12),
              Text(
                'Bé ơi đừng lo nhé! Bé hãy chọn 1 trong 2 cách dưới đây nha:',
                style: AppTypography.bodySm(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Cách 1: Vẽ lại nét rõ hơn
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.palette_rounded, size: 24, color: AppColors.primaryDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cách 1: Vẽ lại nét rõ hơn',
                            style: AppTypography.labelMd(
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Tẩy bớt nét thừa hoặc vẽ thêm mắt mũi',
                            style: AppTypography.bodySm(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onRedraw();
                      },
                      style: DrawingStyles.outlineRoundedBtn,
                      child: const Text('Vẽ Lại'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Cách 2: Nhập hoặc nói ý tưởng và tự chọn loại nhân vật
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mic_rounded, size: 22, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cách 2: Nói hoặc ghi ý tưởng của bé',
                            style: AppTypography.labelMd(
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ideaController,
                      maxLines: 2,
                      style: AppTypography.bodySm(
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Khủng long màu xanh biết bay, mặc áo choàng đỏ...',
                        hintStyle: AppTypography.bodySm(
                          color: AppColors.outline,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.mic_rounded,
                            color: AppColors.secondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _ideaController.text =
                                  'Bạn nhỏ có đôi cánh thần kỳ và nụ cười rạng rỡ';
                            });
                            widget.onShowToast?.call(
                              'Đã nhận giọng nói của bé: "Bạn nhỏ có đôi cánh thần kỳ!"',
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chọn loại nhân vật bé thích:',
                      style: AppTypography.labelSm(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.availableCharTypes.map((ct) {
                          final isSel = (ct.id == _selectedCharTypeId);
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                ct.name,
                                style: const TextStyle(fontSize: 11),
                              ),
                              selected: isSel,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCharTypeId = ct.id;
                                  _selectedCharTypeName = ct.name;
                                });
                              },
                              selectedColor: AppColors.primaryFixed,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Button to generate with child's idea
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onGenerate(
                    drawingId: widget.analyzeData.drawingId,
                    originalImageUrl: widget.analyzeData.originalImageUrl,
                    charTypeId: _selectedCharTypeId,
                    charTypeName: _selectedCharTypeName,
                    standardizedPrompt: null,
                    childAdditionalIdea: _ideaController.text.trim().isNotEmpty
                        ? _ideaController.text.trim()
                        : null,
                    detectedTags: null,
                    isRegenerate: false,
                  );
                },
                style: DrawingStyles.primaryRoundedBtn,
                child: Text(
                  'Tạo Nhân Vật Với Ý Tưởng Này',
                  style: AppTypography.labelMd(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

