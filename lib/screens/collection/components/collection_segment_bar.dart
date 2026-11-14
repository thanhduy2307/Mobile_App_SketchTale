import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../collection_styles.dart';

/// 🔘 Thanh chuyển Segment (Nhân vật 3D | Truyện đã đọc | Thành tích)
class CollectionSegmentBar extends StatelessWidget {
  final int activeSegment;
  final int characterCount;
  final ValueChanged<int> onSegmentChanged;

  const CollectionSegmentBar({
    super.key,
    required this.activeSegment,
    required this.characterCount,
    required this.onSegmentChanged,
  });

  Widget _buildSegmentButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = (activeSegment == index);
    return Expanded(
      child: GestureDetector(
        onTap: () => onSegmentChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelSm(
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: CollectionStyles.segmentContainerDecoration,
          child: Row(
            children: [
              _buildSegmentButton(
                index: 0,
                icon: Icons.palette_outlined,
                label: 'Nhân vật ($characterCount)',
              ),
              _buildSegmentButton(
                index: 1,
                icon: Icons.menu_book_rounded,
                label: 'Truyện đã đọc',
              ),
              _buildSegmentButton(
                index: 2,
                icon: Icons.workspace_premium_outlined,
                label: 'Thành tích',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

