import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../role_assignment_styles.dart';

/// 💡 Hướng dẫn các bước gán vai
class RoleStepInstruction extends StatelessWidget {
  const RoleStepInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: RoleAssignmentStyles.stepInstructionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bé ơi, ai sẽ đóng vai trong truyện?',
            style: AppTypography.labelMd(color: AppColors.onSecondaryFixed),
          ),
          Text(
            'Gán tranh bé vẽ để bắt đầu hành trình nhé!',
            style: AppTypography.bodyMd(color: AppColors.onSecondaryFixedVariant),
          ),
        ],
      ),
    );
  }
}

