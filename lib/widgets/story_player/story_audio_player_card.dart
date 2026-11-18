import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Kid-friendly Interactive Audio Player Card for StoryPlayerScreen
/// Provides real-time audio playback controls, dancing waveform visualizer,
/// scrubbing slider, and 5-second rewind.
class StoryAudioPlayerCard extends StatefulWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onTogglePlay;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onRewind5s;
  final String narratorName;
  final String? audioUrl;

  const StoryAudioPlayerCard({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onRewind5s,
    this.narratorName = 'Chú Gấu Pô',
    this.audioUrl,
  });

  @override
  State<StoryAudioPlayerCard> createState() => _StoryAudioPlayerCardState();
}

class _StoryAudioPlayerCardState extends State<StoryAudioPlayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isPlaying) {
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StoryAudioPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_waveController.isAnimating) {
      _waveController.repeat(reverse: true);
    } else if (!widget.isPlaying && _waveController.isAnimating) {
      _waveController.stop();
      _waveController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final posMs = widget.position.inMilliseconds.toDouble();
    final durMs = widget.duration.inMilliseconds > 0
        ? widget.duration.inMilliseconds.toDouble()
        : 57000.0; // Realistic default audio length
    final clampedPos = posMs.clamp(0.0, durMs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isPlaying
              ? const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]
              : const [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isPlaying ? const Color(0xFF0284C7) : AppColors.outline,
          width: widget.isPlaying ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isPlaying
                ? const Color(0x280284C7)
                : const Color(0x0C001050),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Narrator Badge & Waveform Visualizer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.isPlaying
                          ? const Color(0xFF0284C7)
                          : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isPlaying ? 'ĐANG PHÁT LỜI KỂ' : 'NGHE GIỌNG ĐỌC KỲ DIỆU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: widget.isPlaying
                          ? const Color(0xFF0369A1)
                          : AppColors.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),

              // Animated Sound Waves
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  final t = _waveController.value;
                  return Row(
                    children: List.generate(5, (index) {
                      final wave = widget.isPlaying
                          ? (0.3 + 0.7 * math.sin((t * 2 + index * 0.7) * math.pi).abs())
                          : 0.25;
                      final height = 10.0 + wave * 16.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: widget.isPlaying
                              ? const Color(0xFF0284C7)
                              : AppColors.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Middle: Interactive Slider & Timestamp Labels
          Row(
            children: [
              Text(
                _formatDuration(widget.position),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF0284C7),
                    inactiveTrackColor: const Color(0xFFCBD5E1),
                    thumbColor: const Color(0xFF0284C7),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: clampedPos,
                    min: 0.0,
                    max: durMs,
                    onChanged: (val) {
                      widget.onSeek(Duration(milliseconds: val.round()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(Duration(milliseconds: durMs.round())),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Bottom Control Buttons: [↺ 5s] and [Play/Pause]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 5 seconds
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onRewind5s,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay_5_rounded, size: 20, color: Color(0xFF0284C7)),
                      SizedBox(width: 4),
                      Text(
                        '5s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Main Play / Pause 3D Button
              Squishy3DButton(
                onPressed: widget.onTogglePlay,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: widget.isPlaying
                    ? AppColors.tertiary
                    : const Color(0xFF0284C7),
                bevelColor: widget.isPlaying
                    ? const Color(0xFF841630)
                    : const Color(0xFF0369A1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isPlaying ? 'Tạm Dừng' : 'Nghe Kể',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
