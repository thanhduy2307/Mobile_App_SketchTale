import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../app_loading.dart';

/// Clean Dedicated Vocabulary Tab View with interactive cards
class StoryVocabularyTab extends StatelessWidget {
  final List<VocabularyTemplate> vocabList;
  final Set<String> learnedVocabIds;
  final bool isLoading;
  final String storyTitle;
  final ValueChanged<VocabularyTemplate> onVocabTap;
  final VoidCallback onBackToReader;
  final VoidCallback? onGoToQuiz;
  final VoidCallback? onOpenAnimationControls;

  const StoryVocabularyTab({
    super.key,
    required this.vocabList,
    required this.learnedVocabIds,
    required this.isLoading,
    required this.storyTitle,
    required this.onVocabTap,
    required this.onBackToReader,
    this.onGoToQuiz,
    this.onOpenAnimationControls,
  });

  @override
  Widget build(BuildContext context) {
    final learnedCount = vocabList.where((v) => learnedVocabIds.contains(v.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vocabulary Header Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1810B981),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
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
                child: const Center(
                  child: Icon(Icons.menu_book_rounded, size: 24, color: Color(0xFF065F46)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kho Từ Vựng',
                      style: AppTypography.headlineSm(color: const Color(0xFF065F46)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bé đã hiểu $learnedCount/${vocabList.length} từ trong truyện',
                      style: AppTypography.bodySm(color: const Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Vocabulary Cards List
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const AppLoadingLogo(
              size: 56,
              label: 'Đang tải từ vựng của truyện...',
            ),
          )
        else if (vocabList.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              'Chưa có từ vựng cho trang này',
              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          )
        else
          for (final vocab in vocabList)
            GestureDetector(
              onTap: () => onVocabTap(vocab),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: learnedVocabIds.contains(vocab.id)
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: learnedVocabIds.contains(vocab.id)
                            ? const Color(0xFFD1FAE5)
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          learnedVocabIds.contains(vocab.id)
                              ? Icons.check_circle_rounded
                              : Icons.menu_book_rounded,
                          size: 22,
                          color: learnedVocabIds.contains(vocab.id)
                              ? const Color(0xFF059669)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vocab.word,
                            style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vocab.meaning,
                            style: AppTypography.bodySm(color: AppColors.secondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),

        const SizedBox(height: 12),

        // Navigation Footer between Tabs
        Row(
          children: [
            Expanded(
              child: Squishy3DButton(
                onPressed: onBackToReader,
                height: 46,
                backgroundColor: AppColors.surfaceContainer,
                bevelColor: AppColors.surfaceDim,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_rounded, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text('Đọc Truyện', style: AppTypography.labelMd(color: AppColors.secondary)),
                  ],
                ),
              ),
            ),
            if (onOpenAnimationControls != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Squishy3DButton(
                  onPressed: () {
                    onBackToReader();
                    onOpenAnimationControls?.call();
                  },
                  height: 46,
                  backgroundColor: const Color(0xFF8B5CF6),
                  bevelColor: const Color(0xFF7C3AED),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.theater_comedy_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Chỉnh Hoạt Họa', style: AppTypography.labelMd(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ] else if (onGoToQuiz != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Squishy3DButton(
                  onPressed: onGoToQuiz!,
                  height: 46,
                  backgroundColor: const Color(0xFFF59E0B),
                  bevelColor: const Color(0xFFD97706),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Sang Đố Vui', style: AppTypography.labelMd(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
