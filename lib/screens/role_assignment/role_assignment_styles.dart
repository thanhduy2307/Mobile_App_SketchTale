import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 🎨 Stylesheet cho Role Assignment Screen
class RoleAssignmentStyles {
  RoleAssignmentStyles._();

  static BoxDecoration summaryCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFFE4E2DD),
        offset: Offset(0, 4),
        blurRadius: 0,
      ),
    ],
  );

  static BoxDecoration stepInstructionDecoration = BoxDecoration(
    color: AppColors.secondaryFixed,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
  );

  static BoxDecoration roleSlotDecoration({
    required bool isTarget,
    required bool hasCharacter,
  }) {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isTarget
            ? AppColors.primary
            : (hasCharacter ? AppColors.accentMint : AppColors.outline),
        width: isTarget ? 2.5 : 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isTarget ? const Color(0x22F59E0B) : const Color(0x0A000000),
          offset: const Offset(0, 4),
          blurRadius: isTarget ? 12 : 4,
        ),
      ],
    );
  }

  static BoxDecoration characterCardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.outline),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0C000000),
        offset: Offset(0, 2),
        blurRadius: 6,
      ),
    ],
  );
}

