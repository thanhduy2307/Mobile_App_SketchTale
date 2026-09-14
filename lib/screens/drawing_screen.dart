import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'magic_transform_screen.dart';

class DrawingScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenParentGate;

  const DrawingScreen({
    super.key,
    required this.appState,
    required this.onOpenParentGate,
  });

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _onMagicTransform() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MagicTransformScreen(
          appState: widget.appState,
          onOpenParentGate: widget.onOpenParentGate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Switcher Mode Pills (Bé tự vẽ vs Chụp tranh giấy)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => state.setScannerMode(false)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !state.isCameraScannerMode
                            ? AppColors.surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: !state.isCameraScannerMode
                            ? [
                                const BoxShadow(
                                  color: Color(0xFFD6C4AC),
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.brush_rounded,
                            size: 20,
                            color: !state.isCameraScannerMode
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bé tự vẽ 🖌️',
                            style: AppTypography.labelMd(
                              color: !state.isCameraScannerMode
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => state.setScannerMode(true)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: state.isCameraScannerMode
                            ? AppColors.surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: state.isCameraScannerMode
                            ? [
                                const BoxShadow(
                                  color: Color(0xFFD6C4AC),
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_rounded,
                            size: 20,
                            color: state.isCameraScannerMode
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Chụp tranh giấy 📸',
                            style: AppTypography.labelMd(
                              color: state.isCameraScannerMode
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Drawing Board / Paper Stage
          Container(
            height: 310,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFFE4E2DD),
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Paper canvas texture background
                  Positioned.fill(
                    child: Container(
                      color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
                      child: CustomPaint(
                        painter: GridDotsPainter(),
                      ),
                    ),
                  ),

                  // Background guide illustration (optional subtle art)
                  if (!state.isCameraScannerMode && state.strokeLines.isEmpty)
                    Center(
                      child: Opacity(
                        opacity: 0.45,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBs1j3zRcevls4hct7nBLNl-MkQnsK7toexPnjvrTD6o6grUe5LRVFr48TmDhOkJRfp5Y4vH9CBxVELjUEZjdk4_PwjzWXqSy_jPmk5x8lm-6H8YcUa_VmryBJa7ZbuS-RvYRs3HFFNUR0ER83b8VqqyfVywEVMGXGWhsd64VL4q00kJkrvW8cj30w-LJRCoY6LJxTsWfvShrWvjBoiwMYTe8nRFsuOj1pcrEeyCZPjTibGAPFHUwpG',
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.cruelty_free_rounded,
                                size: 90,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chạm tay vào khung để vẽ nhé!',
                              style: AppTypography.labelSm(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Interactive Custom Drawing Canvas
                  if (!state.isCameraScannerMode)
                    Positioned.fill(
                      child: GestureDetector(
                        onPanStart: (details) {
                          state.startNewStroke();
                          state.addStrokePoint(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          state.addStrokePoint(details.localPosition);
                        },
                        child: CustomPaint(
                          painter: FreehandPainter(lines: state.strokeLines),
                          size: Size.infinite,
                        ),
                      ),
                    ),

                  // Camera Scanner Simulated Frame
                  if (state.isCameraScannerMode)
                    Positioned.fill(
                      child: Container(
                        color: AppColors.primaryContainer.withValues(alpha: 0.12),
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryContainer,
                              width: 3,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.photo_camera_rounded,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 6),
                                  ],
                                ),
                                child: Text(
                                  'Căn tranh bé vẽ vừa khung này nhé!',
                                  style: AppTypography.labelMd(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Top-Left Badge: "Khung vẽ thần kỳ"
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Khung vẽ thần kỳ',
                            style: AppTypography.labelSm(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Right Quick Action Utilities (Undo & Clear)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        ChunkyIconButton(
                          size: 40,
                          borderDepth: 3,
                          backgroundColor: Colors.white,
                          borderColor: AppColors.outlineVariant,
                          icon: const Icon(Icons.undo_rounded, size: 20, color: AppColors.onSurface),
                          onPressed: () => setState(() => state.undoStroke()),
                        ),
                        const SizedBox(width: 8),
                        ChunkyIconButton(
                          size: 40,
                          borderDepth: 3,
                          backgroundColor: AppColors.errorContainer,
                          borderColor: const Color(0xFFFFB4AB),
                          icon: const Icon(Icons.delete_forever_rounded, size: 20, color: AppColors.onErrorContainer),
                          onPressed: () => setState(() => state.clearCanvas()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Drawing Studio Floating Console
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE4E2DD),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Palette buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildColorButton(
                      color: AppColors.primaryContainer,
                      borderColor: const Color(0xFFD99800),
                      isSelected: !state.isEraserMode && state.currentBrushColor == AppColors.primaryContainer,
                      onTap: () => setState(() => state.setBrushColor(AppColors.primaryContainer)),
                    ),
                    _buildColorButton(
                      color: AppColors.secondaryContainer,
                      borderColor: const Color(0xFFB53C1A),
                      isSelected: !state.isEraserMode && state.currentBrushColor == AppColors.secondaryContainer,
                      onTap: () => setState(() => state.setBrushColor(AppColors.secondaryContainer)),
                    ),
                    _buildColorButton(
                      color: AppColors.tertiaryContainer,
                      borderColor: const Color(0xFF1D96CF),
                      isSelected: !state.isEraserMode && state.currentBrushColor == AppColors.tertiaryContainer,
                      onTap: () => setState(() => state.setBrushColor(AppColors.tertiaryContainer)),
                    ),
                    _buildColorButton(
                      color: AppColors.accentMint,
                      borderColor: AppColors.accentMintDark,
                      isSelected: !state.isEraserMode && state.currentBrushColor == AppColors.accentMint,
                      onTap: () => setState(() => state.setBrushColor(AppColors.accentMint)),
                    ),
                    _buildColorButton(
                      color: AppColors.accentLilac,
                      borderColor: AppColors.accentLilacDark,
                      isSelected: !state.isEraserMode && state.currentBrushColor == AppColors.accentLilac,
                      onTap: () => setState(() => state.setBrushColor(AppColors.accentLilac)),
                    ),
                    // Magic Eraser Button
                    _buildEraserButton(
                      isSelected: state.isEraserMode,
                      onTap: () => setState(() => state.setEraserMode(!state.isEraserMode)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Brush size selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.draw_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Nét bút bé chọn:',
                          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          _buildBrushSizeOption(size: 4.0, dotSize: 6.0, currentSize: state.currentBrushSize, onTap: () => setState(() => state.setBrushSize(4.0))),
                          const SizedBox(width: 8),
                          _buildBrushSizeOption(size: 8.0, dotSize: 10.0, currentSize: state.currentBrushSize, onTap: () => setState(() => state.setBrushSize(8.0))),
                          const SizedBox(width: 8),
                          _buildBrushSizeOption(size: 16.0, dotSize: 15.0, currentSize: state.currentBrushSize, onTap: () => setState(() => state.setBrushSize(16.0))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hero CTA: "Biến thành Hoạt Hình! ✨"
          ChunkyButton(
            height: 64,
            borderDepth: 6,
            backgroundColor: AppColors.secondaryContainer,
            borderColor: const Color(0xFFB53C1A),
            foregroundColor: Colors.white,
            onPressed: _onMagicTransform,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(0, -4 * _sparkleController.value),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.auto_fix_high_rounded,
                    size: 28,
                    color: AppColors.primaryFixed,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Biến thành Hoạt Hình! ✨',
                  style: AppTypography.headlineMd(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Micro helper hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Bé vẽ xong, ấn nút thần kỳ để Bút Phép biến hình 3D nhé!',
                    style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildColorButton({
    required Color color,
    required Color borderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check_rounded, size: 22, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildEraserButton({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.secondary, width: 2)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFC7C2B8),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.auto_fix_normal_rounded,
            size: 22,
            color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBrushSizeOption({
    required double size,
    required double dotSize,
    required double currentSize,
    required VoidCallback onTap,
  }) {
    final bool isSelected = (currentSize == size);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0xFFD6C4AC),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Canvas Grid Dots Texture
class GridDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF847560).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    const double spacing = 24.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Freehand drawing painter
class FreehandPainter extends CustomPainter {
  final List<List<DrawingPoint>> lines;

  FreehandPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      if (line.isEmpty) continue;
      if (line.length == 1) {
        canvas.drawCircle(line[0].offset, line[0].paint.strokeWidth / 2, line[0].paint);
        continue;
      }
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i].offset, line[i + 1].offset, line[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FreehandPainter oldDelegate) => true;
}
