import 'package:flutter/material.dart';
import '../../../models/drawing_ai_models.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../drawing_styles.dart';

/// 🎨 Dialog Giai đoạn 1: Bút thần nhận diện thành công nét vẽ của bé
/// Cho bé xem các đặc điểm bút thần nhận ra, chọn bạn nhỏ gợi ý to rõ, sinh động và thêm phép thuật/ý tưởng.
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

    // Bảng màu pastel xoay vòng cho các đặc điểm tags
    final pastelColors = [
      (
        bg: const Color(0xFFFFFBEB),
        border: const Color(0xFFFCD34D),
        text: const Color(0xFFB45309),
        icon: const Color(0xFFD97706),
      ),
      (
        bg: const Color(0xFFF5F3FF),
        border: const Color(0xFFDDD6FE),
        text: const Color(0xFF6D28D9),
        icon: const Color(0xFF7C3AED),
      ),
      (
        bg: const Color(0xFFF0F9FF),
        border: const Color(0xFFBAE6FD),
        text: const Color(0xFF0369A1),
        icon: const Color(0xFF0284C7),
      ),
      (
        bg: const Color(0xFFF0FDF4),
        border: const Color(0xFFBBF7D0),
        text: const Color(0xFF15803D),
        icon: const Color(0xFF16A34A),
      ),
      (
        bg: const Color(0xFFFDF2F8),
        border: const Color(0xFFFBCFE8),
        text: const Color(0xFFBE185D),
        icon: const Color(0xFFDB2777),
      ),
    ];

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
              // 1. Banner Tiêu Đề Bút Thần Vui Nhộn & Nút Đóng
              Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFD97706),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Bút Thần Đã Nhận Ra Nhân Vật!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF92400E),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
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
              const SizedBox(height: 18),

              // 2. Các đặc điểm nhận diện (Tags từ BE) - To rõ & Sinh động
              if (widget.analyzeData.detectedTags.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.palette_rounded,
                      size: 18,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Nét vẽ nổi bật trong tranh của bé:',
                      style: AppTypography.labelMd(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.analyzeData.detectedTags.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tag = entry.value;
                    final style = pastelColors[idx % pastelColors.length];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: style.border, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: style.icon,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: style.text,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // 3. Danh sách Loại Nhân Vật Gợi Ý - To bản, bắt mắt, dễ chạm
              Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 20,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bé muốn biến hình thành bạn nào?',
                    style: AppTypography.headlineSm(color: AppColors.onSurface),
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
