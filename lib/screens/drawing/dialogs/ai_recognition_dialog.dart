import 'package:flutter/material.dart';
import '../../../models/drawing_ai_models.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

/// Dialog Giai doan 1: Meo Miu nhan dien thanh cong net ve cua be
/// Cho be chon ban nho goi y to ro, sinh dong va them phep thuat/y tuong.
class AiRecognitionDialog extends StatefulWidget {
  final AnalyzeDrawingResponse analyzeData;
  final List<CharType> fallbackCharTypes;
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

  const AiRecognitionDialog({
    super.key,
    required this.analyzeData,
    required this.fallbackCharTypes,
    required this.onGenerate,
    required this.onRedraw,
  });

  @override
  State<AiRecognitionDialog> createState() => _AiRecognitionDialogState();
}

class _AiRecognitionDialogState extends State<AiRecognitionDialog> {
  late final TextEditingController _ideaController;
  late String _selectedCharTypeId;
  late String _selectedCharTypeName;

  @override
  void initState() {
    super.initState();
    _ideaController = TextEditingController();

    final suggested = widget.analyzeData.suggestedCharTypes;
    if (suggested.isNotEmpty) {
      _selectedCharTypeId = suggested.first.id;
      _selectedCharTypeName = suggested.first.displayName;
    } else if (widget.fallbackCharTypes.isNotEmpty) {
      _selectedCharTypeId = widget.fallbackCharTypes.first.id;
      _selectedCharTypeName = widget.fallbackCharTypes.first.name;
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

  IconData _getIconForChar(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fish') || lower.contains('cá')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('cat') || lower.contains('mèo')) {
      return Icons.pets_rounded;
    }
    if (lower.contains('dog') || lower.contains('chó') || lower.contains('cún')) {
      return Icons.pets_rounded;
    }
    if (lower.contains('bird') || lower.contains('chim')) {
      return Icons.flutter_dash_rounded;
    }
    if (lower.contains('dragon') ||
        lower.contains('rồng') ||
        lower.contains('khủng long')) {
      return Icons.terrain_rounded;
    }
    if (lower.contains('rabbit') || lower.contains('thỏ')) {
      return Icons.cruelty_free_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  String _friendlyName(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower == 'fish') return 'Chú Cá Nhỏ';
    if (lower == 'cat') return 'Bạn Mèo Con';
    if (lower == 'dog') return 'Chú Cún Con';
    if (lower == 'bird') return 'Chú Chim Nhỏ';
    if (lower == 'rabbit') return 'Bạn Thỏ Trắng';
    if (lower == 'dragon') return 'Bạn Rồng Con';
    if (lower == 'bear') return 'Chú Gấu Con';
    if (raw.isNotEmpty) {
      return raw[0].toUpperCase() + raw.substring(1);
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final suggested = widget.analyzeData.suggestedCharTypes;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        width: 460,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFCD34D), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tieu de chon ban nho & Nut Dong
              Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 20,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bé muốn biến hình thành bạn nào?',
                      style: AppTypography.headlineSm(color: AppColors.onSurface),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.outline),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Danh sách thẻ gợi ý to bản
              if (suggested.isNotEmpty)
                Column(
                  children: suggested.map((t) {
                    final isSel = (t.id == _selectedCharTypeId);
                    final charIcon = _getIconForChar(t.displayName);
                    final vietnameseName = _friendlyName(t.displayName);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCharTypeId = t.id;
                            _selectedCharTypeName = t.displayName;
                          });
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFFFFFBEB)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                              width: isSel ? 2.2 : 1.2,
                            ),
                            boxShadow: isSel
                                ? const [
                                    BoxShadow(
                                      color: Color(0x14D97706),
                                      offset: Offset(0, 3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFFFEF3C7)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? const Color(0xFFFCD34D)
                                        : AppColors.outlineVariant,
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    charIcon,
                                    size: 22,
                                    color: isSel
                                        ? const Color(0xFFD97706)
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vietnameseName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSel
                                            ? const Color(0xFF92400E)
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                    if (vietnameseName.toLowerCase() !=
                                        t.displayName.toLowerCase()) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '(${t.displayName})',
                                        style: AppTypography.bodySm(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                isSel
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 24,
                                color: isSel
                                    ? const Color(0xFFD97706)
                                    : AppColors.outline,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                // Fallback nếu danh sách suggested rỗng
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.fallbackCharTypes.map((ct) {
                    final isSel = (ct.id == _selectedCharTypeId);
                    return ChoiceChip(
                      label: Text(
                        ct.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: const Color(0xFFFEF3C7),
                      onSelected: (_) {
                        setState(() {
                          _selectedCharTypeId = ct.id;
                          _selectedCharTypeName = ct.name;
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // 4. Nhập thêm chi tiết phép thuật của bé
              Row(
                children: [
                  const Icon(
                    Icons.auto_fix_high_rounded,
                    size: 18,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Thêm nét đặc biệt cho bạn nhỏ (nếu bé thích):',
                    style: AppTypography.labelSm(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _ideaController,
                style: AppTypography.bodySm(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Đội mũ hiệp sĩ, đeo ba lô phiêu lưu, có cánh...',
                  hintStyle: AppTypography.bodySm(color: AppColors.outline),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 5. Nút hành động to bản: Vẽ Lại hoặc Biến Hình Nhân Vật
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onRedraw();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.outline, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Vẽ Lại',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onGenerate(
                            drawingId: widget.analyzeData.drawingId,
                            originalImageUrl: widget.analyzeData.originalImageUrl,
                            charTypeId: _selectedCharTypeId,
                            charTypeName: _selectedCharTypeName,
                            standardizedPrompt: widget.analyzeData.standardizedPrompt,
                            childAdditionalIdea: _ideaController.text.trim().isNotEmpty
                                ? _ideaController.text.trim()
                                : null,
                            detectedTags: widget.analyzeData.detectedTags,
                            isRegenerate: false,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_fix_high_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Biến Hình Bạn Nhỏ Này!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
