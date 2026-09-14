import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'role_assignment_screen.dart';
import 'story_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenDrawing;
  final VoidCallback onOpenParentGate;

  const LibraryScreen({
    super.key,
    required this.appState,
    required this.onOpenDrawing,
    required this.onOpenParentGate,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Tất cả', 'icon': Icons.apps_rounded},
    {'name': 'Phiêu lưu', 'icon': Icons.rocket_launch_rounded},
    {'name': 'Động vật 🦁', 'icon': Icons.pets_rounded},
    {'name': 'Gia đình & Bạn bè 🎈', 'icon': Icons.celebration_rounded},
    {'name': 'Khoa học vui 🔬', 'icon': Icons.science_rounded},
  ];

  void _openStory(Story story) {
    widget.appState.setCurrentStory(story);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleAssignmentScreen(
          appState: widget.appState,
          onOpenParentGate: widget.onOpenParentGate,
        ),
      ),
    );
  }

  void _resumeReading(Story story) {
    widget.appState.setCurrentStory(story);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPlayerScreen(
          appState: widget.appState,
          story: story,
          onOpenParentGate: widget.onOpenParentGate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final storiesFiltered = (state.selectedCategory == 'Tất cả')
        ? state.stories
        : state.stories.where((s) => s.category.contains(state.selectedCategory)).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Playful Daily Hero & Mascot Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE6BE8A),
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Mascot Image
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.brush_rounded,
                                size: 44,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.waving_hand_rounded, size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text('Chào ${state.kidName}!', style: AppTypography.labelSm(color: AppColors.secondary)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hôm nay mình cùng sáng tạo truyện mới nhé! ✨',
                            style: AppTypography.headlineMd(color: AppColors.onPrimaryFixed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Hero Action 3D Button: "Vẽ nhân vật ngay! 🎨"
                ChunkyButton(
                  height: 52,
                  borderDepth: 4,
                  backgroundColor: AppColors.primaryContainer,
                  borderColor: const Color(0xFFB37D00),
                  foregroundColor: AppColors.onPrimaryContainer,
                  onPressed: widget.onOpenDrawing,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.draw_rounded, size: 24),
                      const SizedBox(width: 8),
                      Text('Vẽ nhân vật ngay! 🎨', style: AppTypography.labelLg(color: AppColors.onPrimaryContainer)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Star Streak & Reward Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFEAE8E2),
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFB37D00), offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.onPrimaryContainer,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chuỗi sáng tạo', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
                        Text('${state.streakDays} ngày liên tiếp 🎉', style: AppTypography.headlineMd(color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 22),
                      const SizedBox(width: 4),
                      Text('${state.stars}', style: AppTypography.headlineMd(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Topic Filters Horizontal Carousel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chủ đề yêu thích', style: AppTypography.headlineMd(color: AppColors.onSurface)),
              Text('Tất cả (${state.stories.length})', style: AppTypography.labelSm(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = (state.selectedCategory == cat['name']);
                return GestureDetector(
                  onTap: () => state.setCategory(cat['name'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : const Color(0xFFE4E2DD),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? const Color(0xFF752300) : const Color(0xFFDBDAD4),
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['name'] as String,
                          style: AppTypography.labelMd(
                            color: isSelected ? Colors.white : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Featured Stories Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark_rounded, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 6),
                  Text('Truyện bé vừa hoàn thành 📚', style: AppTypography.headlineMd(color: AppColors.onSurface)),
                ],
              ),
              Text('${storiesFiltered.length} cuốn', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),

          // Stories Shelf Cards
          Column(
            children: storiesFiltered.map((story) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFEAE8E2),
                      offset: Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cover thumbnail
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            story.coverUrl,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 68,
                              height: 68,
                              color: AppColors.primaryContainer,
                              child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                            ),
                          ),
                        ),
                        if (story.isCompleted)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Title & progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                story.isCompleted
                                    ? 'Hoàn thành 100%'
                                    : 'Đang đọc dở (Trang ${story.currentPage}/${story.totalPages})',
                                style: AppTypography.labelSm(
                                  color: story.isCompleted ? AppColors.tertiary : AppColors.secondary,
                                ),
                              ),
                              if (story.isCompleted) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.primaryContainer),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            story.title,
                            style: AppTypography.headlineMd(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            story.subtitle,
                            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!story.isCompleted) ...[
                            const SizedBox(height: 6),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (story.currentPage / story.totalPages).clamp(0.1, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Action button
                    ChunkyIconButton(
                      size: 44,
                      borderDepth: 3,
                      backgroundColor: story.isCompleted ? AppColors.surfaceContainerHigh : AppColors.secondaryContainer,
                      borderColor: story.isCompleted ? const Color(0xFFD6C4AC) : const Color(0xFFAB340B),
                      icon: Icon(
                        story.isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                        size: 24,
                        color: story.isCompleted ? AppColors.onSurfaceVariant : Colors.white,
                      ),
                      onPressed: () {
                        if (story.isCompleted) {
                          _openStory(story);
                        } else {
                          _resumeReading(story);
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
