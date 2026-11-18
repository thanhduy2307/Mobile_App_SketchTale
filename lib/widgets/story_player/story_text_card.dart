import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// Single word token with weighted read-along progress brackets [startPct, endPct].
class StoryWordToken {
  final String text;
  final String trailingSpace;
  final double weight;
  final double startPct;
  final double endPct;

  const StoryWordToken({
    required this.text,
    required this.trailingSpace,
    required this.weight,
    required this.startPct,
    required this.endPct,
  });
}

/// Tokenized paragraph containing a list of [StoryWordToken].
class StoryParagraphTokens {
  final List<StoryWordToken> words;
  const StoryParagraphTokens(this.words);
}

/// Internal segment combining tokens for vocabulary matching and audio alignment.
class _StorySegment {
  final String text;
  final String trailingSpace;
  final double startPct;
  final double endPct;
  final VocabularyTemplate? vocab;

  bool get isVocab => vocab != null;

  const _StorySegment({
    required this.text,
    required this.trailingSpace,
    required this.startPct,
    required this.endPct,
    this.vocab,
  });
}

/// Parses multi-paragraph text using Weighted Linear Alignment
/// to align words and natural speech punctuation pauses to spoken audio.
List<StoryParagraphTokens> parseStoryWordTokens(String fullText) {
  if (fullText.trim().isEmpty) return const [];

  final rawParagraphs = fullText.split('\n');
  final List<List<Map<String, dynamic>>> intermediate = [];
  double totalWeight = 0.0;

  for (final p in rawParagraphs) {
    final trimmed = p.trim();
    if (trimmed.isEmpty) {
      intermediate.add([]);
      continue;
    }
    // Dam bao dau cau dinh sat tu (vi du ",Tu" hoac "mam,Tu") duoc tach khoang trang hop ly
    final normalizedParagraph = p.replaceAllMapped(
      RegExp(r'([.,!?:;])(?=\S)'),
      (m) => '${m.group(1)} ',
    );
    final rawWords = normalizedParagraph.split(RegExp(r'\s+'));
    final List<Map<String, dynamic>> pWords = [];
    for (int i = 0; i < rawWords.length; i++) {
      final w = rawWords[i];
      if (w.isEmpty) continue;

      double weight = w.length.toDouble();
      // Natural speech pauses
      if (w.endsWith(',') || w.endsWith(';') || w.endsWith(':')) {
        weight += 2.5;
      } else if (w.endsWith('.') || w.endsWith('!') || w.endsWith('?')) {
        weight += 4.5;
      }
      if (weight < 1.5) weight = 1.5;

      totalWeight += weight;
      pWords.add({
        'word': w,
        'trailing': (i == rawWords.length - 1) ? '' : ' ',
        'weight': weight,
      });
    }
    intermediate.add(pWords);
  }

  if (totalWeight <= 0) totalWeight = 1.0;

  double accumulated = 0.0;
  final List<StoryParagraphTokens> result = [];

  for (final pWords in intermediate) {
    if (pWords.isEmpty) {
      result.add(const StoryParagraphTokens([]));
      continue;
    }
    final List<StoryWordToken> tokens = [];
    for (final m in pWords) {
      final w = m['word'] as String;
      final tr = m['trailing'] as String;
      final weight = m['weight'] as double;

      final startPct = accumulated / totalWeight;
      accumulated += weight;
      final endPct = accumulated / totalWeight;

      tokens.add(StoryWordToken(
        text: w,
        trailingSpace: tr,
        weight: weight,
        startPct: startPct,
        endPct: endPct,
      ));
    }
    result.add(StoryParagraphTokens(tokens));
  }

  return result;
}

/// Kid-Friendly Story Text Card with Real-Time Karaoke Audio Highlighting & Interactive Vocabularies
/// - Highlights vocabulary items set by CM with tap-to-learn interactive badges
/// - Accompanied by animated SketchTale mascot in the bottom-right corner
class StoryTextCard extends StatefulWidget {
  final String textContent;
  final String? englishSubtitle;
  final bool showEnglish;
  final String narratorName;
  final Duration? audioPosition;
  final Duration? audioDuration;
  final bool isPlayingAudio;
  final ValueChanged<Duration>? onSeekAudio;
  final List<VocabularyTemplate> vocabularies;
  final ValueChanged<VocabularyTemplate>? onVocabTap;

  const StoryTextCard({
    super.key,
    required this.textContent,
    this.englishSubtitle,
    required this.showEnglish,
    this.narratorName = 'Chú Gấu Pô',
    this.audioPosition,
    this.audioDuration,
    this.isPlayingAudio = false,
    this.onSeekAudio,
    this.vocabularies = const [],
    this.onVocabTap,
  });

  @override
  State<StoryTextCard> createState() => _StoryTextCardState();
}

class _StoryTextCardState extends State<StoryTextCard>
    with SingleTickerProviderStateMixin {
  double _fontSizeDelta = 0.0; // -2.0, 0.0, +3.0

  String? _cachedRawText;
  List<StoryParagraphTokens> _cachedParagraphs = const [];

  late final AnimationController _mascotController;
  late final Animation<double> _mascotFloatAnimation;
  bool _isMascotJumping = false;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _mascotFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mascotController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  List<StoryParagraphTokens> _getParagraphs(String text) {
    if (_cachedRawText == text && _cachedParagraphs.isNotEmpty) {
      return _cachedParagraphs;
    }
    _cachedRawText = text;
    _cachedParagraphs = parseStoryWordTokens(text);
    return _cachedParagraphs;
  }

  /// Chuẩn hóa từ để so khớp chính xác: loại bỏ dấu câu, chữ thường
  String _cleanWord(String s) {
    return s
        .replaceAll(RegExp(r'[.,!?:;"“”‘’\(\)\[\]\{\}]'), '')
        .trim()
        .toLowerCase();
  }

  /// Gom nhóm các token từ theo danh sách từ vựng của CM
  List<_StorySegment> _buildSegments(
    List<StoryWordToken> tokens,
    List<VocabularyTemplate> vocabList,
  ) {
    if (tokens.isEmpty) return const [];
    if (vocabList.isEmpty) {
      return tokens
          .map((t) => _StorySegment(
                text: t.text,
                trailingSpace: t.trailingSpace,
                startPct: t.startPct,
                endPct: t.endPct,
                vocab: null,
              ))
          .toList();
    }

    // Sắp xếp danh sách từ vựng theo số lượng từ giảm dần (ưu tiên cụm từ dài trước)
    final sortedVocabs = List<VocabularyTemplate>.from(vocabList);
    sortedVocabs.sort((a, b) {
      final aCount = a.word.trim().split(RegExp(r'\s+')).length;
      final bCount = b.word.trim().split(RegExp(r'\s+')).length;
      return bCount.compareTo(aCount);
    });

    final List<_StorySegment> segments = [];
    int i = 0;
    while (i < tokens.length) {
      VocabularyTemplate? matchedVocab;
      int matchedCount = 0;

      for (final v in sortedVocabs) {
        final vWords = v.word
            .trim()
            .split(RegExp(r'\s+'))
            .map(_cleanWord)
            .where((w) => w.isNotEmpty)
            .toList();
        if (vWords.isEmpty) continue;

        if (i + vWords.length <= tokens.length) {
          bool allMatch = true;
          for (int k = 0; k < vWords.length; k++) {
            if (_cleanWord(tokens[i + k].text) != vWords[k]) {
              allMatch = false;
              break;
            }
          }
          if (allMatch) {
            matchedVocab = v;
            matchedCount = vWords.length;
            break;
          }
        }
      }

      if (matchedVocab != null && matchedCount > 0) {
        final matchedTokens = tokens.sublist(i, i + matchedCount);
        final combinedText = matchedTokens.map((t) => t.text).join(' ');
        final trailing = matchedTokens.last.trailingSpace;
        segments.add(_StorySegment(
          text: combinedText,
          trailingSpace: trailing,
          startPct: matchedTokens.first.startPct,
          endPct: matchedTokens.last.endPct,
          vocab: matchedVocab,
        ));
        i += matchedCount;
      } else {
        segments.add(_StorySegment(
          text: tokens[i].text,
          trailingSpace: tokens[i].trailingSpace,
          startPct: tokens[i].startPct,
          endPct: tokens[i].endPct,
          vocab: null,
        ));
        i++;
      }
    }

    return segments;
  }

  void _triggerMascotJump() {
    if (_isMascotJumping) return;
    setState(() => _isMascotJumping = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isMascotJumping = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = 19.0 + _fontSizeDelta;

    final pos = widget.audioPosition ?? Duration.zero;
    final dur = widget.audioDuration ?? Duration.zero;
    final bool hasValidDuration = dur > Duration.zero;
    final double progress = hasValidDuration
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    // Highlight is active whenever playing or when paused mid-story (position > 0)
    final bool isReadAlongActive = hasValidDuration &&
        (widget.isPlayingAudio || (pos > Duration.zero && progress < 0.99));

    final cleanContent = widget.textContent.trim();
    final bool hasValidText = cleanContent.isNotEmpty &&
        cleanContent.toLowerCase() != 'string' &&
        cleanContent.toLowerCase() != 'null';

    final paragraphs = _getParagraphs(
      hasValidText
          ? cleanContent
          : 'Ngày xửa ngày xưa, trong một thế giới thần tiên rực rỡ, các bạn nhỏ cùng nhau khám phá một câu chuyện diệu kỳ và đầy ắp niềm vui...',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isReadAlongActive
              ? const Color(0xFFFBBF24) // Glowing amber border when audio is active
              : AppColors.outline,
          width: isReadAlongActive ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isReadAlongActive
                ? const Color(0x1AF59E0B)
                : const Color(0x0E001050),
            offset: const Offset(0, 4),
            blurRadius: isReadAlongActive ? 16 : 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Goc Doc Truyen & Font Zoom Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isReadAlongActive
                          ? const Color(0xFFFEF3C7)
                          : AppColors.primaryFixed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isReadAlongActive
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFFCD34D),
                      ),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 17,
                      color: isReadAlongActive
                          ? const Color(0xFFB45309)
                          : const Color(0xFF8A5A00),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Góc Đọc Truyện Của Bé',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_fontSizeDelta > -2.0) _fontSizeDelta -= 2.0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_fontSizeDelta < 4.0) _fontSizeDelta += 2.0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8A5A00))),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Read-Along Status Pill when Audio is active
          if (isReadAlongActive) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isPlayingAudio ? Icons.volume_up_rounded : Icons.pause_rounded,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.isPlayingAudio
                        ? 'Dõi theo giọng đọc • Đang phát'
                        : 'Dõi theo giọng đọc • Tạm dừng',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 3. Main Vietnamese Story Text with Real-Time Word Highlighting & Interactive Vocab
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int pIdx = 0; pIdx < paragraphs.length; pIdx++) ...[
                if (pIdx > 0) const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final segments = _buildSegments(
                      paragraphs[pIdx].words,
                      widget.vocabularies,
                    );
                    return Text.rich(
                      TextSpan(
                        children: segments.map((seg) {
                          final bool isLastSegment = (pIdx == paragraphs.length - 1) &&
                              (seg == segments.last);
                          final bool isHighlightActive = isReadAlongActive &&
                              progress >= seg.startPct &&
                              (progress < seg.endPct || isLastSegment);
                          final bool isPast = isReadAlongActive && progress >= seg.endPct;

                          // Neu tu nay la tu vung CM: Render highlight nhe nhang, khong icon ruom ra
                          if (seg.isVocab) {
                            return TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (widget.onVocabTap != null) {
                                        widget.onVocabTap!(seg.vocab!);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isHighlightActive
                                            ? const Color(0xFFFDE68A)
                                            : const Color(0xFFFEF3C7).withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        seg.text,
                                        style: TextStyle(
                                          fontSize: baseFontSize,
                                          height: 1.35,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF92400E),
                                          decoration: TextDecoration.underline,
                                          decorationColor: const Color(0xFFD97706).withValues(alpha: 0.6),
                                          decorationThickness: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: seg.trailingSpace,
                                  style: TextStyle(fontSize: baseFontSize),
                                ),
                              ],
                            );
                          }

                          // Từ ngữ thông thường
                          TextStyle spanStyle;
                          if (isHighlightActive) {
                            spanStyle = TextStyle(
                              fontSize: baseFontSize,
                              height: 1.62,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF78350F),
                              backgroundColor: const Color(0xFFFEF08A),
                              letterSpacing: 0.3,
                            );
                          } else if (isPast) {
                            spanStyle = TextStyle(
                              fontSize: baseFontSize,
                              height: 1.62,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              letterSpacing: 0.2,
                            );
                          } else if (isReadAlongActive) {
                            spanStyle = TextStyle(
                              fontSize: baseFontSize,
                              height: 1.62,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface.withValues(alpha: 0.58),
                              letterSpacing: 0.2,
                            );
                          } else {
                            spanStyle = TextStyle(
                              fontSize: baseFontSize,
                              height: 1.62,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              letterSpacing: 0.2,
                            );
                          }

                          return TextSpan(
                            text: '${seg.text}${seg.trailingSpace}',
                            style: spanStyle,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),

          // 4. Linh Vat O Goc Phai Dong Hanh & Nhac Be Doc Tu Vung
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _buildMascotReminder(),
          ),
        ],
      ),
    );
  }

  /// Linh vat SketchTale hoat hoa o goc phai voi bong thoai nhac nho
  Widget _buildMascotReminder() {
    return AnimatedBuilder(
      animation: _mascotFloatAnimation,
      builder: (context, child) {
        final floatOffset = -5.0 * _mascotFloatAnimation.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bong bong loi thoai cua linh vat
            GestureDetector(
              onTap: _triggerMascotJump,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12, right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(3),
                  ),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                    width: 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  'Bé đừng quên đọc từ vựng nhé!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),

            // Linh vật chuyển động nhấp nhô vui nhộn
            GestureDetector(
              onTap: _triggerMascotJump,
              child: Transform.translate(
                offset: Offset(0, floatOffset + (_isMascotJumping ? -12 : 0)),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x12000000),
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/SketchTale_Mascot_Loading.webp',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/bobby-chinh-dien.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
