import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_picker_helper.dart';
import '../../utils/responsive.dart';
import 'components/drawing_canvas_area.dart';
import 'components/drawing_mode_selector.dart';
import 'components/drawing_palette_bar.dart';
import 'components/drawing_toolbar.dart';
import 'drawing_controller.dart';

export 'drawing_controller.dart';
export 'drawing_styles.dart';
export 'drawing_types.dart';

/// Man hinh Ve Tranh & Tao Nhan Vat 3D (Clean View Component)
/// Cau truc theo phong cach React JSX + CSS: View chi render bo cuc giao dien,
/// toan bo Logic nam trong [DrawingController], Style nam trong [DrawingStyles].
class DrawingScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onOpenCollection;

  const DrawingScreen({
    super.key,
    required this.appState,
    this.onOpenCollection,
  });

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late final DrawingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DrawingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.primaryContainer,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.labelMd(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.onSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  Future<void> _triggerImageUpload() async {
    _showToast('Đang mở thư mục để bé chọn ảnh từ máy...');
    final picked = await pickImageFromDevice();
    if (picked == null || picked.bytes.isEmpty) {
      if (mounted) {
        _controller.setActiveDrawMode(0);
      }
      return;
    }

    if (mounted) {
      _showToast('Đã tải ảnh lên thành công! Mèo Miu đang biến hình...');
      _controller.startTransformWorkflow(
        context: context,
        appState: widget.appState,
        onOpenCollection: widget.onOpenCollection,
        onToast: _showToast,
        overrideBytes: picked.bytes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final isTablet = Responsive.isTabletOrDesktop(context);
    final canvasHeight = isTablet ? 420.0 : 340.0;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Responsive.kMaxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header & Bộ chuyển chế độ vẽ (Vẽ tay vs Chụp tranh giấy)
                  DrawingModeSelector(
                    activeDrawMode: _controller.activeDrawMode,
                    parentCredits: state.parentCredits,
                    remainingLimit: state.remainingCharacterLimit,
                    onModeChanged: (mode) => _controller.setActiveDrawMode(mode),
                    onCameraTap: _triggerImageUpload,
                  ),

                  const SizedBox(height: 12),

                  // 2. Khung vẽ chính: Thanh công cụ + Canvas + Bảng màu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD8E3FB),
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toolbar: Bút vẽ, Đổ màu, Cục tẩy, Undo, Clear
                        DrawingToolbar(
                          currentTool: _controller.currentTool,
                          onSelectTool: (tool) =>
                              _controller.selectTool(tool, onToast: _showToast),
                          onUndo: () =>
                              _controller.undo(state, onToast: _showToast),
                          onClear: () =>
                              _controller.clearCanvas(state, onToast: _showToast),
                        ),

                        const SizedBox(height: 10),

                        // Canvas Area cảm ứng
                        DrawingCanvasArea(
                          canvasKey: _controller.canvasKey,
                          canvasHeight: canvasHeight,
                          currentTool: _controller.currentTool,
                          strokeLines: state.strokeLines,
                          fillImage: _controller.currentFillImage,
                          onBucketTap: (pos, sz) =>
                              _controller.handleBucketTap(pos, sz, state),
                          onPanStart: (pos, sz) =>
                              _controller.handlePanStart(pos, sz, state),
                          onPanUpdate: (pos, sz) =>
                              _controller.handlePanUpdate(pos, sz, state),
                        ),

                        const SizedBox(height: 10),

                        // Palette Bar & Brush / Eraser thickness
                        DrawingPaletteBar(
                          currentTool: _controller.currentTool,
                          selectedColorIndex: _controller.selectedColorIndex,
                          brushSize: _controller.brushSize,
                          eraserSize: _controller.eraserSize,
                          onSelectColor: (idx) => _controller.selectColor(idx),
                          onSelectBrushSize: (sz) =>
                              _controller.setBrushSize(sz),
                          onSelectEraserSize: (sz) =>
                              _controller.setEraserSize(sz),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Nút chính: Biến hình tranh vẽ thành nhân vật 3D
                  Squishy3DButton.primary(
                    onPressed: () => _controller.startTransformWorkflow(
                      context: context,
                      appState: state,
                      onOpenCollection: widget.onOpenCollection,
                      onToast: _showToast,
                    ),
                    height: 56,
                    depth: 5,
                    child: Center(
                      child: Text(
                        'Biến Hình Nhân Vật',
                        style: AppTypography.headlineSm(color: AppColors.onPrimary).copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

