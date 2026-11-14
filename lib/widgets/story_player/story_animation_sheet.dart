import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../squash_stretch_character.dart';

/// Modal Bottom Sheet cho phép người dùng tùy chỉnh hoạt họa nhân vật thời gian thực
class StoryAnimationSheet extends StatefulWidget {
  final AnimationMode currentMode;
  final CharacterAction currentAction;
  final double currentScale;
  final bool flipHorizontal;
  final ValueChanged<AnimationMode> onModeChanged;
  final ValueChanged<CharacterAction> onActionChanged;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<bool> onFlipChanged;
  final VoidCallback onScreenShake;
  final VoidCallback onSpawnFireflies;
  final VoidCallback? onResetPosition;
  final VoidCallback? onTriggerJump;

  const StoryAnimationSheet({
    super.key,
    required this.currentMode,
    required this.currentAction,
    required this.currentScale,
    required this.flipHorizontal,
    required this.onModeChanged,
    required this.onActionChanged,
    required this.onScaleChanged,
    required this.onFlipChanged,
    required this.onScreenShake,
    required this.onSpawnFireflies,
    this.onResetPosition,
    this.onTriggerJump,
  });

  @override
  State<StoryAnimationSheet> createState() => _StoryAnimationSheetState();
}

class _StoryAnimationSheetState extends State<StoryAnimationSheet> {
  late AnimationMode _mode;
  late CharacterAction _action;
  late double _scale;
  late bool _flip;

  @override
  void initState() {
    super.initState();
    _mode = widget.currentMode;
    _action = widget.currentAction;
    _scale = widget.currentScale;
    _flip = widget.flipHorizontal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x308B5CF6),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.theater_comedy_rounded, size: 24, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tùy Chỉnh Hoạt Họa',
                        style: AppTypography.headlineSm(color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Thử nghiệm 6 chiêu thức & hiệu ứng vật lý',
                        style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  tooltip: 'Đóng',
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Scrollable controls
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Actions / Chiêu thức
                  _buildSectionTitle('1. Chiêu Thức Nhân Vật (6 Hành Động)'),
                  const SizedBox(height: 10),
                  _buildActionsGrid(),

                  const SizedBox(height: 20),

                  // 2. Chế độ công nghệ
                  _buildSectionTitle('2. Công Nghệ Hoạt Họa & Vật Lý'),
                  const SizedBox(height: 10),
                  _buildModeSelector(),

                  const SizedBox(height: 20),

                  // 3. Kích thước & Lật hướng
                  _buildSectionTitle('3. Kích Thước & Hướng Nhìn'),
                  const SizedBox(height: 10),
                  _buildScaleAndFlipControls(),

                  const SizedBox(height: 20),

                  // 4. Kích hoạt hiệu ứng nhanh
                  _buildSectionTitle('4. Thử Nghiệm Hiệu Ứng Tức Thì'),
                  const SizedBox(height: 10),
                  _buildQuickTriggers(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLg(color: AppColors.onSurface),
    );
  }

  Widget _buildActionsGrid() {
    final actions = [
      (CharacterAction.idle, 'Nhún Thở', Icons.self_improvement_rounded, 'Thư giãn êm dịu'),
      (CharacterAction.patrol, 'Đi Tuần Tra', Icons.directions_walk_rounded, 'Tự qua lại + lật 3D'),
      (CharacterAction.dance, 'Nhảy Disco', Icons.music_note_rounded, 'Xoay 360° + nhạc'),
      (CharacterAction.fly, 'Bay Lượn', Icons.flight_takeoff_rounded, 'Lượn sóng hình sin'),
      (CharacterAction.stomp, 'Đại Địa Chấn', Icons.vibration_rounded, 'Nhún & rung chấn'),
      (CharacterAction.sleep, 'Nằm Ngủ Zzz', Icons.bedtime_rounded, 'Bong bóng Zzz'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((item) {
        final (act, label, icon, desc) = item;
        final isSelected = _action == act;

        return GestureDetector(
          onTap: () {
            setState(() => _action = act);
            widget.onActionChanged(act);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF3E8FF)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x308B5CF6),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: isSelected ? const Color(0xFF8B5CF6) : AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF6B21A8)
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? const Color(0xFF7C3AED)
                              : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      (
        AnimationMode.stateMachine3D,
        '3D Perspective Flip',
        'Xoay 3D theo không gian 3 chiều có chiều sâu',
      ),
      (
        AnimationMode.spineJellyMesh,
        'Spine Jelly Mesh',
        'Mô phỏng Spine/Rive 2D uốn dẻo đàn hồi như thạch',
      ),
    ];

    return Column(
      children: modes.map((item) {
        final (mode, title, desc) = item;
        final isSelected = _mode == mode;

        return GestureDetector(
          onTap: () {
            setState(() => _mode = mode);
            widget.onModeChanged(mode);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFEF3C7)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? const Color(0xFFD97706)
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF92400E)
                              : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? const Color(0xFFB45309)
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScaleAndFlipControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tỷ lệ phóng to:',
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(_scale * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.surfaceContainerHighest,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _scale,
              min: 0.6,
              max: 1.8,
              divisions: 12,
              onChanged: (val) {
                setState(() => _scale = val);
                widget.onScaleChanged(val);
              },
            ),
          ),
          Row(
            children: [
              for (final preset in [0.8, 1.0, 1.3, 1.6]) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: (_scale - preset).abs() < 0.05
                              ? AppColors.secondary
                              : const Color(0xFFCBD5E1),
                        ),
                        backgroundColor: (_scale - preset).abs() < 0.05
                            ? AppColors.secondary.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      onPressed: () {
                        setState(() => _scale = preset);
                        widget.onScaleChanged(preset);
                      },
                      child: Text(
                        '${(preset * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: (_scale - preset).abs() < 0.05
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (_scale - preset).abs() < 0.05
                              ? AppColors.secondary
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hướng quay mặt:',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final newFlip = !_flip;
                  setState(() => _flip = newFlip);
                  widget.onFlipChanged(newFlip);
                },
                icon: Icon(
                  _flip ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  _flip ? 'Đang quay Trái' : 'Đang quay Phải',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTriggers() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTriggerPill(
          icon: Icons.vibration_rounded,
          label: 'Rung Chấn',
          color: const Color(0xFFEF4444),
          onTap: widget.onScreenShake,
        ),
        _buildTriggerPill(
          icon: Icons.auto_awesome_rounded,
          label: 'Thả Đom Đóm',
          color: const Color(0xFFF59E0B),
          onTap: widget.onSpawnFireflies,
        ),
        _buildTriggerPill(
          icon: Icons.arrow_upward_rounded,
          label: 'Nhảy Tưng Tưng',
          color: const Color(0xFF10B981),
          onTap: widget.onTriggerJump ?? () {},
        ),
        _buildTriggerPill(
          icon: Icons.my_location_rounded,
          label: 'Đặt Lại Vị Trí',
          color: const Color(0xFF3B82F6),
          onTap: widget.onResetPosition ?? () {},
        ),
      ],
    );
  }

  Widget _buildTriggerPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      onPressed: onTap,
    );
  }
}
