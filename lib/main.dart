import 'package:flutter/material.dart';
import 'screens/collection_screen.dart';
import 'screens/drawing_screen.dart';
import 'screens/library_screen.dart';
import 'screens/parent_gate_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SketchTaleApp());
}

class SketchTaleApp extends StatefulWidget {
  const SketchTaleApp({super.key});

  @override
  State<SketchTaleApp> createState() => _SketchTaleAppState();
}

class _SketchTaleAppState extends State<SketchTaleApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SketchTale - Kể Chuyện Tương Tác Cùng Bé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryContainer,
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
        ),
      ),
      home: MainShellScreen(appState: _appState),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final AppState appState;

  const MainShellScreen({super.key, required this.appState});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0; // 0: Library, 1: Drawing, 2: Collection

  void _openParentGate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParentGateScreen(appState: widget.appState),
      ),
    );
  }

  String _getTabSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Thư Viện Truyện';
      case 1:
        return 'Bé Vẽ Tranh';
      case 2:
        return 'Bộ Sưu Tập Của Bé';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo & Brand
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.brush_rounded,
                              size: 22,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SketchTale',
                            style: AppTypography.headlineMd(color: AppColors.primary),
                          ),
                          Text(
                            _getTabSubtitle(),
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Actions: Star badge, Parental Gate lock, Profile avatar
                  Row(
                    children: [
                      // Stars Count Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFE4E2DD),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.primaryContainer,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${state.stars}',
                              style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Parental Gate Lock Icon
                      ChunkyIconButton(
                        size: 38,
                        borderDepth: 2,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        borderColor: const Color(0xFFD6C4AC),
                        icon: const Icon(
                          Icons.lock_rounded,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: _openParentGate,
                      ),
                      const SizedBox(width: 8),

                      // Profile Avatar
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: IndexedStack(
            index: _currentIndex,
            children: [
              LibraryScreen(
                appState: state,
                onOpenDrawing: () => setState(() => _currentIndex = 1),
                onOpenParentGate: _openParentGate,
              ),
              DrawingScreen(
                appState: state,
                onOpenParentGate: _openParentGate,
              ),
              CollectionScreen(
                appState: state,
                onOpenDrawing: () => setState(() => _currentIndex = 1),
                onOpenParentGate: _openParentGate,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tab 1: Thư viện truyện
                _buildNavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Thư viện',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),

                // Center Raised Action: Bé vẽ
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD99800),
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.palette_rounded,
                          size: 28,
                          color: AppColors.onPrimaryContainer,
                        ),
                        Text(
                          'Bé vẽ',
                          style: AppTypography.labelSm(color: AppColors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Bộ sưu tập
                _buildNavItem(
                  icon: Icons.stars_rounded,
                  label: 'Bộ sưu tập',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSm(
                color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
