import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'role_assignment_screen.dart';

class CollectionScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenDrawing;
  final VoidCallback onOpenParentGate;

  const CollectionScreen({
    super.key,
    required this.appState,
    required this.onOpenDrawing,
    required this.onOpenParentGate,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _activeSegment = 0; // 0: Characters, 1: Completed stories

  void _playSound(KidCharacter char) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${char.name}: "${char.voicePhrase}"',
                style: AppTypography.labelMd(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onRoleplay(KidCharacter char) {
    widget.appState.setHeroCharacter(char);
    Navigator.of(context).push(
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
    final state = widget.appState;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-banner Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: AppColors.onPrimaryFixed),
                        const SizedBox(width: 4),
                        Text('Tủ đồ kỳ diệu', style: AppTypography.labelSm(color: AppColors.onPrimaryFixed)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gia tài sáng tạo của ${state.kidName} 🎨',
                    style: AppTypography.headlineLg(color: AppColors.primary),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.brush_rounded, color: AppColors.primary, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segment Switcher (Nhân vật của bé vs Truyện đã xong)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeSegment = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeSegment == 0 ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: _activeSegment == 0
                            ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cruelty_free_rounded,
                            size: 18,
                            color: _activeSegment == 0 ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Nhân vật của bé (${state.characters.length})',
                            style: AppTypography.labelMd(
                              color: _activeSegment == 0 ? Colors.white : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeSegment = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeSegment == 1 ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: _activeSegment == 1
                            ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 18,
                            color: _activeSegment == 1 ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Truyện đã xong (2)',
                            style: AppTypography.labelMd(
                              color: _activeSegment == 1 ? Colors.white : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content of Tab 1: Characters View
          if (_activeSegment == 0) ...[
            // Quick Action: Create New Character
            GestureDetector(
              onTap: widget.onOpenDrawing,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4), blurRadius: 0),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFFD99800), offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.onPrimaryContainer, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vẽ bạn mới ngay ✨', style: AppTypography.headlineMd(color: AppColors.primary)),
                          Text('Thổi hồn cho nét vẽ thành nhân vật 3D', style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Character Cards List
            Column(
              children: state.characters.map((char) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar & Sound trigger
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              char.avatar3dUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 90,
                                height: 90,
                                color: AppColors.primaryContainer,
                                child: const Icon(Icons.cruelty_free_rounded, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _playSound(char),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.volume_up_rounded, size: 12, color: AppColors.onTertiaryContainer),
                                    const SizedBox(width: 2),
                                    Text('Nghe', style: AppTypography.labelSm(color: AppColors.onTertiaryContainer)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Info & Actions
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: char.isParentApproved ? AppColors.primaryFixed : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    char.isParentApproved ? Icons.verified_rounded : Icons.schedule_rounded,
                                    size: 12,
                                    color: char.isParentApproved ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    char.isParentApproved ? 'Ba Mẹ duyệt 🌟' : 'Ba Mẹ sắp xem nè! ⏳',
                                    style: AppTypography.labelSm(
                                      color: char.isParentApproved ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(char.name, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                            Text(char.title, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant), maxLines: 1),
                            const SizedBox(height: 8),

                            // Roleplay CTA
                            ChunkyButton(
                              height: 40,
                              borderDepth: 3,
                              backgroundColor: char.isParentApproved ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                              borderColor: char.isParentApproved ? const Color(0xFFD99800) : const Color(0xFFD6C4AC),
                              foregroundColor: char.isParentApproved ? AppColors.onPrimaryContainer : AppColors.onSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              onPressed: char.isParentApproved
                                  ? () => _onRoleplay(char)
                                  : widget.onOpenParentGate,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    char.isParentApproved ? Icons.play_circle_rounded : Icons.lock_clock_rounded,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    char.isParentApproved ? 'Đóng vai truyện' : 'Nhờ Ba Mẹ duyệt',
                                    style: AppTypography.labelSm(
                                      color: char.isParentApproved ? AppColors.onPrimaryContainer : AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Content of Tab 2: Completed Stories View
          if (_activeSegment == 1) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDUnv_tax-sWDIH-HcFWNdoCvgDthGQqiO8QeAOEJWZjUZ_DMAf9NNU_otzEaE3cL7vyc8BIMjqUpV8EU7xlzYL-QTqdkUN6zggac0rhZg76J8esoO9xcstJMlf4ZHDtEDzBw47zuI0RpB9uk_Qg7tXnYH_Dp5rZ1I4Y9nOuhOtYYtJ2b0fX3QMwUkbD3YpFSvmGpCwcaWX4woNntNIbiGCySkl7UnkLdmmk0Nx_owAyXiAvkkA2tKb',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(width: 64, height: 64, color: AppColors.primaryContainer),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Hoàn thành 100%', style: AppTypography.labelSm(color: AppColors.tertiary)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.primaryContainer),
                              ],
                            ),
                            Text('Chú Chó Cứu Hỏa', style: AppTypography.headlineMd(color: AppColors.onSurface)),
                            Text('Tranh vẽ bởi: Bé Bo', style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      ChunkyIconButton(
                        size: 40,
                        borderDepth: 3,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        borderColor: const Color(0xFFD6C4AC),
                        icon: const Icon(Icons.replay_rounded, size: 20, color: AppColors.onSurface),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đang mở lại truyện Chú Chó Cứu Hỏa...')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
