import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../story_player_styles.dart';

/// BottomSheet: Xem chi tiet nghia tu vung & danh dau da hieu
/// Tu dong goi API GET /api/story-vocabulary/{id} de dong bo chi tiet tu vung khi mo.
class VocabDetailSheet extends StatefulWidget {
  final VocabularyTemplate vocab;
  final bool isLearned;
  final VoidCallback onMarkLearned;
  final void Function(String msg) onShowToast;
  final Future<VocabularyTemplate> Function(VocabularyTemplate vocab)? onInspectVocab;

  const VocabDetailSheet({
    super.key,
    required this.vocab,
    required this.isLearned,
    required this.onMarkLearned,
    required this.onShowToast,
    this.onInspectVocab,
  });

  static Future<void> show(
    BuildContext context, {
    required VocabularyTemplate vocab,
    required bool isLearned,
    required VoidCallback onMarkLearned,
    required void Function(String msg) onShowToast,
    Future<VocabularyTemplate> Function(VocabularyTemplate vocab)? onInspectVocab,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => VocabDetailSheet(
        vocab: vocab,
        isLearned: isLearned,
        onMarkLearned: onMarkLearned,
        onShowToast: onShowToast,
        onInspectVocab: onInspectVocab,
      ),
    );
  }

  @override
  State<VocabDetailSheet> createState() => _VocabDetailSheetState();
}

class _VocabDetailSheetState extends State<VocabDetailSheet> {
  late VocabularyTemplate _vocab;

  @override
  void initState() {
    super.initState();
    _vocab = widget.vocab;
    _loadLatestDetail();
  }

  Future<void> _loadLatestDetail() async {
    if (widget.onInspectVocab == null) return;
    final updated = await widget.onInspectVocab!(widget.vocab);
    if (mounted) {
      setState(() => _vocab = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocab = _vocab;
    final isLearned = widget.isLearned;
    final onMarkLearned = widget.onMarkLearned;
    final onShowToast = widget.onShowToast;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: StoryPlayerStyles.bottomSheetDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: StoryPlayerStyles.sheetDragHandle),
          const SizedBox(height: 12),

          // Header: Badge Từ vựng & Nút đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 15,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Từ Vựng Kỳ Diệu Của Bé',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tên từ vựng & Nút phát âm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  vocab.word,
                  style: AppTypography.headlineLg(color: AppColors.onSurface),
                ),
              ),
              IconButton(
                onPressed: () {
                  onShowToast('Chú Gấu Pô phát âm: "${vocab.word}"');
                },
                tooltip: 'Nghe phát âm',
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Giải thích nghĩa
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giải thích nghĩa:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  vocab.meaning,
                  style: AppTypography.bodyMd(color: AppColors.onSurface),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Nút xác nhận đã hiểu
          Squishy3DButton(
            onPressed: () {
              onMarkLearned();
              Navigator.of(context).pop();
            },
            backgroundColor: isLearned
                ? const Color(0xFF10B981)
                : AppColors.primaryContainer,
            bevelColor: isLearned
                ? const Color(0xFF059669)
                : const Color(0xFFD97706),
            height: 48,
            child: Center(
              child: Text(
                isLearned ? 'Bé đã hiểu từ này' : 'Đánh dấu đã hiểu',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
