import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'role_assignment_screen.dart';

class MagicTransformScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenParentGate;

  const MagicTransformScreen({
    super.key,
    required this.appState,
    required this.onOpenParentGate,
  });

  @override
  State<MagicTransformScreen> createState() => _MagicTransformScreenState();
}

class _MagicTransformScreenState extends State<MagicTransformScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late AnimationController _pulseController;
  String _currentSpeech = 'Chào cậu chủ nhỏ! Tớ đã sẵn sàng cùng cậu thám hiểm Rừng Phép Thuật rồi nè, Roar! 🦖';
  int _selectedColorIndex = 0;
  bool _isPlayingVoice = false;

  final List<String> _randomNames = [
    'Khủng Long Cam Bibo',
    'Rồng Lửa Siêu Quậy',
    'Khủng Long Tí Nị',
    'Dũng Sĩ Hạt Dẻ',
    'Bibo Mắt Biếc',
  ];

  final List<Map<String, dynamic>> _capeColors = [
    {'name': 'Cam', 'color': AppColors.secondaryContainer, 'border': const Color(0xFFC48500)},
    {'name': 'Xanh lá', 'color': AppColors.accentMint, 'border': AppColors.accentMintDark},
    {'name': 'Lam', 'color': AppColors.tertiaryContainer, 'border': const Color(0xFF1D96CF)},
    {'name': 'Hồng', 'color': AppColors.accentLilac, 'border': AppColors.accentLilacDark},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Khủng Long Cam Bibo');
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateRandomName() {
    final nextName = _randomNames[Random().nextInt(_randomNames.length)];
    setState(() {
      _nameController.text = nextName;
    });
  }

  void _testVoice() {
    setState(() {
      _isPlayingVoice = true;
      _currentSpeech = 'Roar! Tớ có áo choàng mới màu ${_capeColors[_selectedColorIndex]['name']} cực ngầu nè bé Bo ơi! ✨';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Đang phát giọng nói nhân vật... 🎵',
              style: AppTypography.labelMd(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isPlayingVoice = false);
    });
  }

  void _onSaveAndAssign() {
    // Create new character
    final newChar = KidCharacter(
      id: 'char_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isEmpty ? 'Bạn Nhỏ Dễ Thương' : _nameController.text.trim(),
      title: 'Dũng sĩ rừng xanh',
      description: 'Nhân vật 3D thần kỳ vừa được tạo từ nét vẽ sáng tạo của bé.',
      drawingUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDw-zXfygZyKFaSvFCg1Fz8ZrSwJHhK0ggAoEGcz0nUe3DMEYseojrSYi6piP8P8A89UJxOUrxyXM0jrQnYH1Un-GbrGCzeH8mr443TSkiA_GDY-9OxQy1IGhmeGx685OjIjpqiAl8j0_uvf4yqvtuH5e7jV8iX21OsDoISHqdEjzHvQaEdUFhF2g9Fbffgs9ZiNtAvexDINAVx33Cd7xdvYolHi0C0GOR-zJ0i8OUZCtIeDBtV_wLW',
      avatar3dUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDGY-F9W_RcTD7TpzrX_1niAejsRVIn7BqzvFp9dwnja9olbexo7JUKyAMpE8FbGJgiIz89_SzF7uRA2aqtjsXinvaFTlzfJe_2yUToLpCu6hxm94CCU-NWnhQT12qSIS2lFketw6EG_nqv-KsQ7rJUHPU62X7P-V85gS5pqgHFbt4_9Eo1brLWz-SY-hVNByGmlz4Fx0UkCj7mRhEZrgQM3HwDGpIy2NzmXYbBi2Kjr_-_qYbyyVC7',
      isParentApproved: true,
      voicePhrase: _currentSpeech,
      themeColor: _capeColors[_selectedColorIndex]['color'] as Color,
      assignedRole: 'Dũng Sĩ Rừng Xanh 🦁',
      createdAt: DateTime.now(),
    );

    widget.appState.addCharacter(newChar);
    widget.appState.setHeroCharacter(newChar);
    widget.appState.addStars(10); // Reward for creating character!

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RoleAssignmentScreen(
          appState: widget.appState,
          onOpenParentGate: widget.onOpenParentGate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: ChunkyIconButton(
          size: 40,
          borderDepth: 3,
          backgroundColor: AppColors.surfaceContainer,
          borderColor: const Color(0xFFD6C4AC),
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Phép Thuật Nhân Vật',
          style: AppTypography.headlineMd(color: AppColors.primary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.appState.stars}',
                  style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Celebratory Sparkle Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryContainer,
                    AppColors.secondaryContainer,
                    AppColors.tertiaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: AppColors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tadaa! Nhân vật đã nở! 🎉',
                          style: AppTypography.headlineMd(color: Colors.white),
                        ),
                        Text(
                          'Tranh vẽ bằng tay của bé vừa hóa phép thành bạn thật!',
                          style: AppTypography.labelSm(color: Colors.white.withValues(alpha: 0.95)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Center Stage: Drawing to 3D Mascot Showcase
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE4E2DD),
                    offset: Offset(0, 6),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role fit pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.forest_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Vai diễn: ',
                          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                        Text(
                          'Dũng sĩ tí hon Rừng Xanh 🌲',
                          style: AppTypography.labelSm(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mascot comparison cards
                  Row(
                    children: [
                      // Child's Original Drawing Snippet
                      Expanded(
                        child: Container(
                          height: 180,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tranh gốc',
                                    style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: Text(
                                      'Bút sáp ✨',
                                      style: AppTypography.labelSm(color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDw-zXfygZyKFaSvFCg1Fz8ZrSwJHhK0ggAoEGcz0nUe3DMEYseojrSYi6piP8P8A89UJxOUrxyXM0jrQnYH1Un-GbrGCzeH8mr443TSkiA_GDY-9OxQy1IGhmeGx685OjIjpqiAl8j0_uvf4yqvtuH5e7jV8iX21OsDoISHqdEjzHvQaEdUFhF2g9Fbffgs9ZiNtAvexDINAVx33Cd7xdvYolHi0C0GOR-zJ0i8OUZCtIeDBtV_wLW',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(Icons.brush_rounded, size: 48, color: AppColors.secondary),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Animated 3D Magic Transformation
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              height: 180,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryFixed,
                                    AppColors.surfaceContainer,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.5 + 0.5 * _pulseController.value),
                                  width: 2,
                                ),
                              ),
                              child: child,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Phép màu 3D',
                                    style: AppTypography.labelSm(color: AppColors.primary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 14),
                                        Text('Cấp 1', style: AppTypography.labelSm(color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDGY-F9W_RcTD7TpzrX_1niAejsRVIn7BqzvFp9dwnja9olbexo7JUKyAMpE8FbGJgiIz89_SzF7uRA2aqtjsXinvaFTlzfJe_2yUToLpCu6hxm94CCU-NWnhQT12qSIS2lFketw6EG_nqv-KsQ7rJUHPU62X7P-V85gS5pqgHFbt4_9Eo1brLWz-SY-hVNByGmlz4Fx0UkCj7mRhEZrgQM3HwDGpIy2NzmXYbBi2Kjr_-_qYbyyVC7',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, _, _) => const Center(
                                          child: Icon(Icons.cruelty_free_rounded, size: 48, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: _testVoice,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer,
                                            borderRadius: BorderRadius.circular(9999),
                                            boxShadow: const [
                                              BoxShadow(color: Color(0xFFD99800), offset: Offset(0, 2)),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _isPlayingVoice ? Icons.graphic_eq_rounded : Icons.record_voice_over_rounded,
                                                size: 14,
                                                color: AppColors.onPrimaryContainer,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Thử giọng!',
                                                style: AppTypography.labelSm(color: AppColors.onPrimaryContainer),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Speech Bubble Preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_rounded, size: 18, color: AppColors.onPrimaryContainer),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '"$_currentSpeech"',
                            style: AppTypography.bodyMd(color: AppColors.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Naming Input Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      'Bé đặt tên cho bạn mới:',
                      style: AppTypography.labelLg(color: AppColors.onSurface),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _generateRandomName,
                  icon: const Icon(Icons.casino_rounded, size: 18, color: AppColors.primary),
                  label: Text('Tên ngẫu nhiên', style: AppTypography.labelSm(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFE4E2DD),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd(color: AppColors.onSurface),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                    onPressed: () => _nameController.clear(),
                  ),
                  border: InputBorder.none,
                  hintText: 'Gõ tên bạn ấy vào đây...',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Cape & Accessories Customization
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đổi màu áo choàng & phụ kiện:',
                    style: AppTypography.labelMd(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_capeColors.length, (idx) {
                      final item = _capeColors[idx];
                      final isSelected = (_selectedColorIndex == idx);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = idx),
                          child: Container(
                            margin: EdgeInsets.only(right: idx < _capeColors.length - 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? item['color'] : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? item['border'] : const Color(0xFFD6C4AC),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? item['border'] : const Color(0xFFE4E2DD),
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                item['name'],
                                style: AppTypography.labelSm(
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary Save & Assign Role Button
            ChunkyButton(
              height: 62,
              borderDepth: 6,
              backgroundColor: AppColors.secondaryContainer,
              borderColor: const Color(0xFFB53C1A),
              foregroundColor: Colors.white,
              onPressed: _onSaveAndAssign,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch_rounded, size: 26, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Lưu & Gán vai đọc truyện ngay! 🚀',
                    style: AppTypography.headlineMd(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
