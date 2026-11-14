import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_config.dart';
import 'app_loading.dart';

/// Compact status banner shown across screens when Fallback / Offline data is active
class FallbackStatusBar extends StatelessWidget {
  final AppState appState;

  const FallbackStatusBar({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        if (!appState.isFallbackMode) return const SizedBox.shrink();

        final featuresText = appState.activeFallbackFeatures.isNotEmpty
            ? appState.activeFallbackFeatures.join(', ')
            : 'Toàn bộ dữ liệu';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showFallbackDetailsSheet(context, appState),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB), // Amber 50
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFFDE68A), // Amber 200
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706), // Amber 600
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 14,
                    color: Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Chế độ Ngoại Tuyến (Dữ liệu mẫu): $featuresText',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF92400E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE68A),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Chi tiết',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF78350F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact inline chip indicating a screen/item is using local fallback data
class FallbackBadgeChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const FallbackBadgeChip({
    super.key,
    this.label = 'Dữ liệu mẫu',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: const Color(0xFFFCD34D), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 12, color: Color(0xFFB45309)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet showing detailed breakdown of active Fallback vs Live APIs
void showFallbackDetailsSheet(BuildContext context, AppState appState) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag pill
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.cloud_sync_rounded,
                        color: Color(0xFFD97706),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trạng Thái Dữ Liệu & Kết Nối',
                            style: AppTypography.headlineSm(color: AppColors.onSurface),
                          ),
                          Text(
                            'Thông tin đồng bộ giữa App và Máy Chủ Backend',
                            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Server Status Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MÁY CHỦ BACKEND',
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: appState.isFallbackMode
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  appState.isFallbackMode
                                      ? Icons.cloud_off_rounded
                                      : Icons.check_circle_rounded,
                                  size: 12,
                                  color: appState.isFallbackMode
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appState.isFallbackMode ? 'Ngoại Tuyến' : 'Đã Kết Nối',
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: appState.isFallbackMode
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppConfig.baseUrl,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Feature items status
                Text(
                  'CHI TIẾT CÁC PHÂN HỆ',
                  style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),

                _buildFeatureRow(
                  icon: Icons.child_care_rounded,
                  title: 'Hồ Sơ Bé & Giới Hạn',
                  isFallback: appState.fallbackStatus['Hồ Sơ Của Bé'] ?? false,
                ),
                const SizedBox(height: 8),
                _buildFeatureRow(
                  icon: Icons.auto_stories_rounded,
                  title: 'Thư Viện Truyện Tranh',
                  isFallback: appState.fallbackStatus['Thư Viện Truyện'] ?? false,
                ),
                const SizedBox(height: 8),
                _buildFeatureRow(
                  icon: Icons.theater_comedy_rounded,
                  title: 'Chủng Loại Nhân Vật',
                  isFallback: appState.fallbackStatus['Chủng Loại Nhân Vật'] ?? false,
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded, color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Khi máy chủ Backend (Render) đang khởi động hoặc thiết bị chưa có mạng, ứng dụng tự động dùng dữ liệu mẫu cục bộ để bé không bị gián đoạn vui chơi.',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF92400E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                // Re-sync action button
                Squishy3DButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            AppLoadingLogo(size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Đang thử kết nối lại với máy chủ Backend...'),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                    await appState.syncAllData();
                  },
                  backgroundColor: AppColors.primary,
                  bevelColor: AppColors.primaryDark,
                  foregroundColor: AppColors.onPrimary,
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Thử Kết Nối Lại Backend',
                        style: AppTypography.labelMd(color: AppColors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildFeatureRow({
  required IconData icon,
  required String title,
  required bool isFallback,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isFallback ? const Color(0xFFFDE68A) : AppColors.outline,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isFallback ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            isFallback ? 'Dữ liệu mẫu' : 'Máy chủ Live',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isFallback ? const Color(0xFF92400E) : const Color(0xFF15803D),
            ),
          ),
        ),
      ],
    ),
  );
}
