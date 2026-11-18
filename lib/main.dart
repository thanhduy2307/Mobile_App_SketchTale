import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/collection/collection_screen.dart';
import 'screens/drawing/drawing_screen.dart';
import 'screens/gender_selection/gender_selection_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/login/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/app_config.dart';
import 'utils/responsive.dart';
import 'widgets/app_loading.dart';
import 'widgets/app_screen_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
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
  void initState() {
    super.initState();
    _appState.addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SketchTale - Xứ Sở Tranh Vẽ Kỳ Diệu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.nunito().fontFamily,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
        ),
      ),
      home: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          if (!_appState.isLoggedIn) {
            return LoginScreen(
              appState: _appState,
              onLoginSuccess: () {},
            );
          }
          if (!_appState.hasSelectedGenderTheme) {
            return GenderSelectionScreen(
              appState: _appState,
              onThemeSelected: (theme) {
                _appState.selectGenderTheme(theme);
              },
            );
          }
          return MainShellScreen(appState: _appState);
        },
      ),
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
  int _currentIndex = 0; // 0: Khám phá, 1: Bé Vẽ Tranh, 2: Kể Chuyện, 3: Tủ Đồ

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outline, width: 1.5),
                    ),
                    child: ClipOval(
                      child: widget.appState.childAvatarAsset.startsWith('http')
                          ? Image.network(
                              widget.appState.childAvatarAsset,
                              width: 52,
                              height: 52,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            )
                          : Image.asset(
                              widget.appState.childAvatarAsset,
                              width: 52,
                              height: 52,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appState.kidName,
                        style: AppTypography.headlineMd(
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Độ tuổi: ${widget.appState.childAgeGroupLabel} • ${widget.appState.stars} sao',
                        style: AppTypography.labelSm(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Squishy3DButton.dark(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => _currentIndex = 3);
                },
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hồ Sơ Của Bé & Tủ Đồ',
                      style: AppTypography.labelMd(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Squishy3DButton.primary(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.appState.resetGenderTheme();
                },
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đổi Không Gian Bé Trai / Bé Gái',
                      style: AppTypography.labelMd(color: AppColors.onPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Squishy3DButton.quiet(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.appState.logout();
                },
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đổi Bé Khác / Đăng Xuất',
                      style: AppTypography.labelMd(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getTabSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Khám Phá';
      case 1:
        return 'Bé Vẽ Tranh';
      case 2:
        return 'Kể Chuyện';
      case 3:
        return 'Góc Của Bé';
      default:
        return 'Khám Phá';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return AppScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.88),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 18,
                  ),
                ],
              ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Responsive.kMaxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.horizontalPadding(context),
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & Brand using official sketchtale-widget.png (pulses when loading)
                      Expanded(
                        child: Row(
                          children: [
                            if (state.isAnyLoading)
                              const AppLoadingLogo(size: 38)
                            else
                              Image.asset(
                                'assets/images/sketchtale-widget.png',
                                width: 38,
                                height: 38,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 28,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'SketchTale',
                                    style: AppTypography.headlineSm(
                                      color: AppColors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _getTabSubtitle(),
                                    style: AppTypography.labelSm(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions: Profile avatar
                      GestureDetector(
                        onTap: _showProfileMenu,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A001050),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: state.childAvatarAsset.startsWith('http')
                                ? Image.network(
                                    state.childAvatarAsset,
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.person_rounded,
                                      size: 22,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : Image.asset(
                                    state.childAvatarAsset,
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.person_rounded,
                                      size: 22,
                                      color: AppColors.primary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  appState: state,
                  onOpenDrawing: () => setState(() => _currentIndex = 1),
                  onOpenLibrary: () => setState(() => _currentIndex = 2),
                ),
                DrawingScreen(
                  appState: state,
                  onOpenCollection: () => setState(() => _currentIndex = 3),
                ),
                LibraryScreen(
                  appState: state,
                  onOpenDrawing: () => setState(() => _currentIndex = 1),
                ),
                CollectionScreen(
                  appState: state,
                  onOpenDrawing: () => setState(() => _currentIndex = 1),
                  onOpenLibrary: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: AppColors.outline, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14001050),
                offset: const Offset(0, -4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 0: Khám phá
              Expanded(
                child: _buildBottomNavItem(
                  index: 0,
                  icon: Icons.explore_rounded,
                  label: 'Khám Phá',
                  isSelected: _currentIndex == 0,
                ),
              ),
              // Tab 1: Vẽ tranh
              Expanded(
                child: _buildBottomNavItem(
                  index: 1,
                  icon: Icons.palette_rounded,
                  label: 'Bé Vẽ',
                  isSelected: _currentIndex == 1,
                ),
              ),
              // Tab 2: Thư viện
              Expanded(
                child: _buildBottomNavItem(
                  index: 2,
                  icon: Icons.menu_book_rounded,
                  label: 'Kho Truyện',
                  isSelected: _currentIndex == 2,
                ),
              ),
              // Tab 3: Hồ sơ bé
              Expanded(
                child: _buildBottomNavItem(
                  index: 3,
                  icon: Icons.stars_rounded,
                  label: 'Góc Của Bé',
                  isSelected: _currentIndex == 3,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: isSelected
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFCD34D),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18F59E0B),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSelected ? 26 : 24,
                color: isSelected
                    ? const Color(0xFF92400E)
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF92400E)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
