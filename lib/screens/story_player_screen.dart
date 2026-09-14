import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'quiz_reward_screen.dart';

class StoryPlayerScreen extends StatefulWidget {
  final AppState appState;
  final Story story;
  final VoidCallback onOpenParentGate;

  const StoryPlayerScreen({
    super.key,
    required this.appState,
    required this.story,
    required this.onOpenParentGate,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen>
    with SingleTickerProviderStateMixin {
  int _currentPageIndex = 2; // Default 3rd page (index 2) as in Stitch mockup
  bool _isPlayingAudio = false;
  String _currentSpeed = 'normal'; // 'slow' or 'normal'
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleAudio() {
    setState(() => _isPlayingAudio = !_isPlayingAudio);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isPlayingAudio ? Icons.volume_up_rounded : Icons.pause_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _isPlayingAudio
                  ? 'Đang phát giọng kể cô Ban Mai...'
                  : 'Đã tạm dừng giọng đọc',
              style: AppTypography.labelMd(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _showVocabDialog(VocabItem vocab) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 36,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vocab.word,
                      style: AppTypography.headlineLg(color: AppColors.onSurface),
                    ),
                    const SizedBox(width: 8),
                    ChunkyIconButton(
                      size: 34,
                      borderDepth: 2,
                      backgroundColor: AppColors.surfaceContainer,
                      borderColor: AppColors.outlineVariant,
                      icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đang phát âm: ${vocab.word} (${vocab.phonetic})',
                              style: AppTypography.labelMd(color: Colors.white),
                            ),
                            backgroundColor: AppColors.secondary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  vocab.phonetic,
                  style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    vocab.definition,
                    style: AppTypography.bodyLg(color: AppColors.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ChunkyButton(
                  height: 50,
                  borderDepth: 4,
                  backgroundColor: AppColors.primaryContainer,
                  borderColor: const Color(0xFFD99800),
                  foregroundColor: AppColors.onPrimaryContainer,
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Bé đã hiểu rồi! 🌟', style: AppTypography.labelLg(color: AppColors.onPrimaryContainer)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNextPage() {
    final story = widget.story;
    if (_currentPageIndex < story.pages.length - 1) {
      setState(() => _currentPageIndex++);
    } else {
      // Go to Quiz
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizRewardScreen(
            appState: widget.appState,
            story: widget.story,
            onOpenParentGate: widget.onOpenParentGate,
          ),
        ),
      );
    }
  }

  void _onPrevPage() {
    if (_currentPageIndex > 0) {
      setState(() => _currentPageIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final currentPage = story.pages.isNotEmpty && _currentPageIndex < story.pages.length
        ? story.pages[_currentPageIndex]
        : story.pages.first;

    final progressRatio = (_currentPageIndex + 1) / story.totalPages;

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
          story.title,
          style: AppTypography.headlineMd(color: AppColors.primary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Trang ${_currentPageIndex + 1} / ${story.totalPages}',
                        style: AppTypography.labelMd(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('15 Sao Tích Lũy', style: AppTypography.labelSm(color: AppColors.onPrimaryFixed)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressRatio.clamp(0.05, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Story Illustration Stage
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 4), blurRadius: 0),
                  BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        currentPage.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(
                            child: Icon(Icons.palette_rounded, size: 64, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    // Narrator voice chip
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Giọng kể: ${currentPage.narratorName}', style: AppTypography.labelSm(color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                    // Tap to discover badge
                    if (currentPage.vocab != null)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: () => _showVocabDialog(currentPage.vocab!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Chạm để khám phá ✨',
                                  style: AppTypography.labelSm(color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Chunky Tactile Audio Player
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFE4E2DD), offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  // Play/Pause Button
                  ChunkyButton(
                    height: 48,
                    borderDepth: 4,
                    backgroundColor: AppColors.primaryContainer,
                    borderColor: const Color(0xFFD99800),
                    foregroundColor: AppColors.onPrimaryContainer,
                    onPressed: _toggleAudio,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 24,
                          color: AppColors.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPlayingAudio ? 'Tạm Dừng' : 'Nghe Kể',
                          style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Animated Soundwave Equalizer
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (_, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (i) {
                              final waveH = _isPlayingAudio
                                  ? (8.0 + (i % 3) * 6.0 * _waveController.value)
                                  : 6.0;
                              return Container(
                                width: 4,
                                height: waveH,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Speed Control Toggle
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _currentSpeed = 'slow'),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _currentSpeed == 'slow' ? Colors.white : Colors.transparent,
                              shape: BoxShape.circle,
                              boxShadow: _currentSpeed == 'slow'
                                  ? const [BoxShadow(color: Colors.black12, blurRadius: 3)]
                                  : null,
                            ),
                            child: const Center(child: Text('🐢', style: TextStyle(fontSize: 16))),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _currentSpeed = 'normal'),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _currentSpeed == 'normal' ? Colors.white : Colors.transparent,
                              shape: BoxShape.circle,
                              boxShadow: _currentSpeed == 'normal'
                                  ? const [BoxShadow(color: Colors.black12, blurRadius: 3)]
                                  : null,
                            ),
                            child: const Center(child: Text('🐇', style: TextStyle(fontSize: 16))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Interactive Story Text Card
            Container(
              padding: const EdgeInsets.all(18),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ĐOẠN TRUYỆN TƯƠNG TÁC',
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                      ),
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryContainer, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Paragraph with tappable vocab word
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 8,
                    children: [
                      Text('Ngày xửa ngày xưa, bạn', style: AppTypography.bodyXl(color: AppColors.onSurface)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          widget.appState.heroCharacter?.name ?? 'Khủng Long Cam',
                          style: AppTypography.labelMd(color: AppColors.onPrimaryFixed),
                        ),
                      ),
                      Text('rất', style: AppTypography.bodyXl(color: AppColors.onSurface)),
                      if (currentPage.vocab != null)
                        GestureDetector(
                          onTap: () => _showVocabDialog(currentPage.vocab!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.secondary, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentPage.vocab!.word.toLowerCase(),
                                  style: AppTypography.labelMd(color: AppColors.onSecondaryFixed),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.secondary),
                              ],
                            ),
                          ),
                        ),
                      Text(
                        'bước vào khu rừng thần tiên để tìm kiếm quả táo vàng giúp muôn thú khoẻ mạnh...',
                        style: AppTypography.bodyXl(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFE4E2DD)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '💡 Nhấn vào từ gạch chân để nghe giải nghĩa',
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuizRewardScreen(
                                appState: widget.appState,
                                story: widget.story,
                                onOpenParentGate: widget.onOpenParentGate,
                              ),
                            ),
                          );
                        },
                        child: Text('Làm câu đố 🎯', style: AppTypography.labelSm(color: AppColors.secondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Page Navigation Chunky Buttons
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(
                    height: 54,
                    borderDepth: 4,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    borderColor: const Color(0xFFD6C4AC),
                    foregroundColor: AppColors.onSurface,
                    onPressed: _currentPageIndex > 0 ? _onPrevPage : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text('Trang trước', style: AppTypography.labelLg(color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ChunkyButton(
                    height: 54,
                    borderDepth: 4,
                    backgroundColor: AppColors.secondaryContainer,
                    borderColor: const Color(0xFFB53C1A),
                    foregroundColor: Colors.white,
                    onPressed: _onNextPage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPageIndex < story.pages.length - 1 ? 'Trang tiếp' : 'Làm câu đố 🎯',
                          style: AppTypography.labelLg(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
