import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../login_styles.dart';

/// 👶 Chọn nhanh nhân vật của bé
class LoginKidSelector extends StatelessWidget {
  final String selectedPreset;
  final void Function(String name, String password, String assetPath) onSelect;

  const LoginKidSelector({
    super.key,
    required this.selectedPreset,
    required this.onSelect,
  });

  Widget _buildKidAvatarChoice(String name, String assetPath, String password) {
    final isSelected = selectedPreset == name;
    return GestureDetector(
      onTap: () => onSelect(name, password, assetPath),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFFFEF3C7) : AppColors.surfaceContainerLow,
              border: Border.all(
                color: isSelected ? const Color(0xFFF59E0B) : AppColors.outline,
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x33F59E0B),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primaryFixed,
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? const Color(0xFF92400E) : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: LoginStyles.presetCardDecoration,
      child: Column(
        children: [
          const Text(
            'Bé chọn hình của mình để vào chơi nhé:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF92400E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildKidAvatarChoice('Bé Đổng', 'assets/images/child-avatars/child-01.png', '123456')),
              Expanded(child: _buildKidAvatarChoice('Bé Bo', 'assets/images/child-avatars/child-02.png', '123456')),
              Expanded(child: _buildKidAvatarChoice('Bé Mimi', 'assets/images/child-avatars/child-03.png', '123456')),
            ],
          ),
        ],
      ),
    );
  }
}

