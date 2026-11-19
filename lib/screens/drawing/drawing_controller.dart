import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/drawing_ai_models.dart';
import '../../models/models.dart';
import '../../services/character_service.dart';
import '../../services/drawing_ai_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_config.dart';
import '../../widgets/app_loading.dart';
import 'dialogs/ai_fallback_dialog.dart';
import 'dialogs/ai_recognition_dialog.dart';
import 'dialogs/approval_sent_dialog.dart';
import 'dialogs/character_preview_dialog.dart';
import 'dialogs/creation_limit_dialog.dart';
import 'dialogs/insufficient_credits_dialog.dart';
import 'drawing_styles.dart';
import 'drawing_types.dart';
import 'utils/flood_fill_helper.dart';

/// DrawingController (Tuong duong React Custom Hook `useDrawingScreen`)
/// Quan ly toan bo State, tuong tac Bang ve (Canvas), Lich su (Undo/Clear),
/// va Luong goi AI 2 giai doan (Phan tich net ve -> Sinh anh 3D -> Gui Ba Me duyet).
class DrawingController extends ChangeNotifier {
  final GlobalKey canvasKey = GlobalKey();

  int activeDrawMode = 0; // 0: Vẽ tay, 1: Chụp ngoài giấy
  int selectedColorIndex = 1; // Default: Cam cà rốt
  double brushSize = 6.0;
  double eraserSize = 28.0;
  DrawingTool currentTool = DrawingTool.pen;
  String selectedPersonality = 'Dũng Sĩ';
  String? lastChildProfileId;

  // Flood fill state
  ui.Image? currentFillImage;
  final List<ui.Image> fillHistory = [];
  final List<DrawActionType> actionHistory = [];
  bool isFilling = false;

  void setActiveDrawMode(int mode) {
    if (activeDrawMode == mode) return;
    activeDrawMode = mode;
    notifyListeners();
  }

  void selectTool(DrawingTool tool, {void Function(String msg)? onToast}) {
    currentTool = tool;
    notifyListeners();

    if (onToast != null) {
      if (tool == DrawingTool.bucket) {
        onToast('Đã chọn Đổ Màu! Chạm vào hình để đổ kín màu');
      } else if (tool == DrawingTool.eraser) {
        onToast('Đã chọn Cục Tẩy! Vuốt vào nét vẽ để xóa');
      } else {
        onToast('Đã chọn Bút Vẽ');
      }
    }
  }

  void selectColor(int index) {
    selectedColorIndex = index;
    if (currentTool == DrawingTool.eraser) {
      currentTool = DrawingTool.pen;
    }
    notifyListeners();
  }

  void setBrushSize(double size) {
    brushSize = size;
    if (currentTool == DrawingTool.eraser) {
      currentTool = DrawingTool.pen;
    }
    notifyListeners();
  }

  void setEraserSize(double size) {
    eraserSize = size;
    currentTool = DrawingTool.eraser;
    notifyListeners();
  }

  /// Undo the last action (either a stroke or a flood fill)
  void undo(AppState appState, {void Function(String msg)? onToast}) {
    if (actionHistory.isNotEmpty) {
      final lastAction = actionHistory.removeLast();
      if (lastAction == DrawActionType.fill) {
        if (fillHistory.isNotEmpty) {
          fillHistory.removeLast();
        }
        currentFillImage = fillHistory.isNotEmpty ? fillHistory.last : null;
        notifyListeners();
        onToast?.call('Đã hoàn tác lần đổ màu');
        return;
      }
    }
    if (appState.strokeLines.isNotEmpty) {
      appState.undoLastStroke();
      notifyListeners();
      onToast?.call('Đã hoàn tác nét vẽ');
    }
  }

  /// Clears both stroke lines and fill layers
  void clearCanvas(AppState appState, {void Function(String msg)? onToast}) {
    appState.clearCanvas();
    fillHistory.clear();
    currentFillImage = null;
    actionHistory.clear();
    notifyListeners();
    onToast?.call('Đã làm sạch bảng vẽ để bé vẽ lại từ đầu.');
  }

  /// Xử lý chạm đổ màu (BFS Flood Fill)
  Future<void> handleBucketTap(
    Offset localPos,
    Size size,
    AppState appState,
  ) async {
    if (isFilling) return;
    isFilling = true;

    final newImage = await FloodFillHelper.performFloodFill(
      tapPos: localPos,
      size: size,
      fillColor: DrawingStyles.paletteColors[selectedColorIndex],
      strokeLines: appState.strokeLines,
      currentFillImage: currentFillImage,
    );

    if (newImage != null) {
      fillHistory.add(newImage);
      currentFillImage = newImage;
      actionHistory.add(DrawActionType.fill);
      notifyListeners();
    }

    isFilling = false;
  }

  /// Bắt đầu nét vẽ hoặc tẩy
  void handlePanStart(Offset localPos, Size size, AppState appState) {
    final clampedX = localPos.dx.clamp(0.0, size.width);
    final clampedY = localPos.dy.clamp(0.0, size.height);
    final isEraser = (currentTool == DrawingTool.eraser);

    final paint = Paint()
      ..color = isEraser
          ? Colors.white
          : DrawingStyles.paletteColors[selectedColorIndex]
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isEraser ? eraserSize : brushSize;

    actionHistory.add(DrawActionType.stroke);
    appState.addStrokeLine([
      DrawingPoint(offset: Offset(clampedX, clampedY), paint: paint),
    ]);
    notifyListeners();
  }

  /// Nối dài nét vẽ hoặc tẩy
  void handlePanUpdate(Offset localPos, Size size, AppState appState) {
    final clampedX = localPos.dx.clamp(0.0, size.width);
    final clampedY = localPos.dy.clamp(0.0, size.height);
    final isEraser = (currentTool == DrawingTool.eraser);

    final paint = Paint()
      ..color = isEraser
          ? Colors.white
          : DrawingStyles.paletteColors[selectedColorIndex]
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isEraser ? eraserSize : brushSize;

    appState.appendPointToLastStroke(
      DrawingPoint(offset: Offset(clampedX, clampedY), paint: paint),
    );
    notifyListeners();
  }

  /// Chụp ảnh canvas WYSIWYG trả về PNG bytes
  Future<Uint8List?> captureCanvasBytes(AppState appState) async {
    // 1. Thử chụp từ RepaintBoundary
    try {
      final boundary =
          canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          debugPrint(
            '[DrawingController] Captured canvas via RepaintBoundary: ${pngBytes.length} bytes',
          );
          return pngBytes;
        }
      }
    } catch (e) {
      debugPrint('[DrawingController] RepaintBoundary capture warning: $e');
    }

    // 2. Dự phòng chụp bằng PictureRecorder
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 600, 600));
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 600, 600),
        Paint()..color = Colors.white,
      );
      if (currentFillImage != null) {
        canvas.drawImage(currentFillImage!, Offset.zero, Paint());
      }
      for (final line in appState.strokeLines) {
        if (line.isEmpty) continue;
        if (line.length == 1) {
          canvas.drawCircle(
            line[0].offset,
            line[0].paint.strokeWidth / 2,
            Paint()
              ..color = line[0].paint.color
              ..style = PaintingStyle.fill,
          );
        } else {
          for (int i = 0; i < line.length - 1; i++) {
            canvas.drawLine(line[i].offset, line[i + 1].offset, line[i].paint);
          }
        }
      }
      final picture = recorder.endRecording();
      final img = await picture.toImage(600, 600);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
      debugPrint(
        '[DrawingController] Captured canvas via PictureRecorder: ${pngBytes?.length} bytes',
      );
      return pngBytes;
    } catch (e) {
      debugPrint('[DrawingController] Capture canvas error: $e');
      return null;
    }
  }

  /// Khởi chạy quy trình AI Transform (2 Giai đoạn)
  Future<void> startTransformWorkflow({
    required BuildContext context,
    required AppState appState,
    VoidCallback? onOpenCollection,
    required void Function(String msg) onToast,
    Uint8List? overrideBytes,
  }) async {
    // 1. Kiểm tra giới hạn tạo nhân vật trong ngày
    if (!appState.canCreateCharacter) {
      _showCreationLimitDialog(context, onOpenLibrary: onOpenCollection);
      return;
    }

    // 2. Kiểm tra số dư Credits (cần tối thiểu 180 = 30 phân tích + 150 sinh 3D)
    if (appState.parentCredits < 180) {
      InsufficientCreditsDialog.show(
        context,
        requiredCredits: 180,
        currentCredits: appState.parentCredits,
      );
      return;
    }

    final Uint8List? canvasBytes;
    if (overrideBytes != null && overrideBytes.isNotEmpty) {
      canvasBytes = overrideBytes;
    } else {
      // 3. Kiểm tra nét vẽ trên canvas
      if (appState.strokeLines.isEmpty && currentFillImage == null) {
        onToast('Bé ơi, hãy vẽ bức tranh trước khi biến hình nhé.');
        return;
      }

      // Chụp ảnh canvas
      canvasBytes = await captureCanvasBytes(appState);
    }

    if (canvasBytes == null || canvasBytes.isEmpty) {
      onToast('Không thể xử lý bức tranh của bé, vui lòng thử lại.');
      return;
    }

    if (!context.mounted) return;

    // Hiển thị loading Giai đoạn 1
    _showStage1Loading(context);

    // Xác định childProfileId hợp lệ
    String? effectiveChildProfileId;
    if (appState.activeChildProfile != null &&
        AppConfig.isValidUuid(appState.activeChildProfile!.id)) {
      effectiveChildProfileId = appState.activeChildProfile!.id;
    } else if (appState.childProfiles.isNotEmpty) {
      final valid = appState.childProfiles.firstWhere(
        (p) =>
            AppConfig.isValidUuid(p.id) &&
            p.id != '00000000-0000-0000-0000-000000000000',
        orElse: () => appState.childProfiles.first,
      );
      if (AppConfig.isValidUuid(valid.id) &&
          valid.id != '00000000-0000-0000-0000-000000000000') {
        effectiveChildProfileId = valid.id;
      }
    }

    if (effectiveChildProfileId == null &&
        appState.userRole.toLowerCase() == 'child') {
      effectiveChildProfileId = AppConfig.extractUserIdFromJwt(
        appState.authToken,
      );
    }

    lastChildProfileId = effectiveChildProfileId;

    // Gọi API Giai đoạn 1: Phân tích nét vẽ
    final analyzeRes = await DrawingAiService.analyzeDrawing(
      bytes: canvasBytes,
      drawingType: activeDrawMode,
      childProfileId: effectiveChildProfileId,
      token: appState.authToken,
    );

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Đóng loading

    if (!analyzeRes.isSuccess || analyzeRes.data == null) {
      onToast(
        analyzeRes.errorMessage ??
            'Không thể phân tích hình vẽ. Vui lòng thử lại!',
      );
      return;
    }

    final analyzeData = analyzeRes.data!;

    // Đồng bộ số dư Credit & giới hạn còn lại từ BE
    appState.updateCreditsAndLimits(
      remainingCredits: analyzeData.remainingParentCredits,
      remainingLimit: analyzeData.remainingDailyCharacterLimit,
    );

    // Rẽ nhánh: Nếu AI nhận diện không thành công -> Fallback dialog, ngược lại -> Recognition dialog
    if (!analyzeData.isRecognized) {
      _showFallbackDialog(
        context: context,
        appState: appState,
        analyzeData: analyzeData,
        onOpenCollection: onOpenCollection,
        onToast: onToast,
      );
    } else {
      _showRecognizedDialog(
        context: context,
        appState: appState,
        analyzeData: analyzeData,
        onOpenCollection: onOpenCollection,
        onToast: onToast,
      );
    }
  }

  /// Giai đoạn 2: Gọi POST /api/drawings/generate-character để sinh ảnh 3D
  Future<void> executeStage2Generate({
    required BuildContext context,
    required AppState appState,
    required String drawingId,
    required String originalImageUrl,
    required String charTypeId,
    required String charTypeName,
    required String? standardizedPrompt,
    required String? childAdditionalIdea,
    required List<String>? detectedTags,
    required bool isRegenerate,
    VoidCallback? onOpenCollection,
    required void Function(String msg) onToast,
  }) async {
    final cost = isRegenerate ? 50 : 150;
    if (appState.parentCredits < cost) {
      InsufficientCreditsDialog.show(
        context,
        requiredCredits: cost,
        currentCredits: appState.parentCredits,
      );
      return;
    }

    if (!isRegenerate) {
      appState.useCharacterCreationAttempt();
    }

    // Hiển thị loading Giai đoạn 2
    _showStage2Loading(context, isRegenerate: isRegenerate);

    final genRes = await DrawingAiService.generateCharacter(
      request: GenerateCharacterRequest(
        drawingId: drawingId,
        charTypeId: charTypeId,
        standardizedPrompt: standardizedPrompt,
        childAdditionalIdea: childAdditionalIdea,
        detectedTags: detectedTags,
        isRegenerate: isRegenerate,
      ),
      token: appState.authToken,
    );

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Đóng loading

    if (!genRes.isSuccess || genRes.data == null) {
      onToast(
        genRes.errorMessage ?? 'Không thể tạo nhân vật. Vui lòng thử lại!',
      );
      return;
    }

    final genData = genRes.data!;

    appState.updateCreditsAndLimits(
      remainingCredits: genData.remainingParentCredits,
      remainingLimit: genData.remainingDailyCharacterLimit,
    );

    if (!context.mounted) return;

    // Mở pop-up xem trước bạn 3D
    CharacterPreviewDialog.show(
      context,
      genResponse: genData,
      originalDrawingUrl: originalImageUrl,
      selectedTypeName: charTypeName,
      parentCredits: appState.parentCredits,
      onRetry: () {
        final profileId =
            lastChildProfileId ?? appState.effectiveChildProfileId;
        CharacterService.cancelCharacterPreview(
          characterId: genData.characterId,
          childProfileId: profileId,
          token: appState.authToken,
        );
        appState.removeCharacter(genData.characterId);
        appState.restoreCharacterCreationAttempt();
        onToast('Đã khôi phục 1 lượt tạo cho bé! Bé có thể vẽ lại.');
      },
      onRegenerate: () {
        executeStage2Generate(
          context: context,
          appState: appState,
          drawingId: drawingId,
          originalImageUrl: originalImageUrl,
          charTypeId: charTypeId,
          charTypeName: charTypeName,
          standardizedPrompt: standardizedPrompt,
          childAdditionalIdea: childAdditionalIdea,
          detectedTags: detectedTags,
          isRegenerate: true,
          onOpenCollection: onOpenCollection,
          onToast: onToast,
        );
      },
      onConfirmAndSubmit: (finalName) async {
        final finalImg = genData.generateImageUrl;
        final finalDrawUrl = originalImageUrl.isNotEmpty
            ? originalImageUrl
            : finalImg;
        final profileId =
            lastChildProfileId ?? appState.effectiveChildProfileId;

        // Gọi POST /api/characters/{id}/accept
        final result = await CharacterService.acceptCharacterPreview(
          characterId: genData.characterId,
          childProfileId: profileId,
          token: appState.authToken,
        );

        if (!result.isSuccess) {
          onToast(result.message);
          return;
        }

        // Cập nhật tên nhân vật lên máy chủ Backend nếu có
        if (finalName.isNotEmpty && AppConfig.isValidUuid(genData.characterId)) {
          CharacterService.updateCharacterName(
            characterId: genData.characterId,
            newName: finalName,
            token: appState.authToken,
          ).ignore();
        }

        // Lưu vào AppState & LocalStorage SharedPreferences
        final newChar = KidCharacter(
          id: genData.characterId,
          name: finalName,
          title: 'Nhân vật sáng tạo của bé',
          description:
              'Người bạn 3D kỳ diệu được hóa phép từ chính nét vẽ tay của bé.',
          drawingUrl: finalDrawUrl,
          avatar3dUrl: finalImg,
          personality: charTypeName,
          assignedRole: charTypeName,
          isParentApproved: false,
          voicePhrase:
              'Chào bé yêu! Tớ là bạn $finalName, cùng tớ phiêu lưu vào truyện cổ tích nào!',
          themeColor: AppColors.primaryContainer,
          createdAt: DateTime.now(),
        );

        appState.addNewCharacter(newChar);
        appState.setPersonality(charTypeName);
        // Không cộng sao theo yêu cầu hệ thống không dùng sao thưởng
        // appState.addStars(10);

        clearCanvas(appState);

        if (context.mounted) {
          // Đóng CharacterPreviewDialog trước để không bị xếp chồng modal
          Navigator.of(context, rootNavigator: true).pop();

          ApprovalSentDialog.show(
            context,
            character: newChar,
            onDrawMore: () {},
            onOpenCollection: () => onOpenCollection?.call(),
          );
        }
      },
      onPlayVoice: () {
        onToast(
          'Bạn 3D: "Chào bé yêu! Tớ là bạn $charTypeName, cùng đi phiêu lưu vào truyện cổ tích nào!"',
        );
      },
    );
  }

  // --- PRIVATE DIALOG HELPERS ---

  void _showStage1Loading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: DrawingStyles.dialogCardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryFixed.withValues(alpha: 0.45),
                    ),
                  ),
                  const AppLoadingLogo(size: 68),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Mèo Miu Đang Ngắm Tranh...',
                style: AppTypography.headlineMd(color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Mèo Miu đang đoán xem bức tranh của bé là bạn nhỏ nào nhé...',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStage2Loading(BuildContext context, {required bool isRegenerate}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: DrawingStyles.dialogCardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryFixed.withValues(alpha: 0.45),
                    ),
                  ),
                  const AppLoadingLogo(size: 68),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Đang Thổi Hồn Phép Thuật...',
                style: AppTypography.headlineMd(color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                isRegenerate
                    ? 'Mèo Miu đang biến hóa diện mạo mới cho bạn nhỏ...'
                    : 'Mèo Miu đang vẽ nên người bạn nhỏ tuyệt đẹp cho bé...',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreationLimitDialog(BuildContext context, {VoidCallback? onOpenLibrary}) {
    CreationLimitDialog.show(
      context,
      onOpenLibrary: onOpenLibrary,
    );
  }

  void _showFallbackDialog({
    required BuildContext context,
    required AppState appState,
    required AnalyzeDrawingResponse analyzeData,
    VoidCallback? onOpenCollection,
    required void Function(String msg) onToast,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AiFallbackDialog(
        analyzeData: analyzeData,
        availableCharTypes: appState.charTypes,
        onGenerate:
            ({
              required String drawingId,
              required String originalImageUrl,
              required String charTypeId,
              required String charTypeName,
              String? standardizedPrompt,
              String? childAdditionalIdea,
              List<String>? detectedTags,
              bool isRegenerate = false,
            }) {
              executeStage2Generate(
                context: context,
                appState: appState,
                drawingId: drawingId,
                originalImageUrl: originalImageUrl,
                charTypeId: charTypeId,
                charTypeName: charTypeName,
                standardizedPrompt: standardizedPrompt,
                childAdditionalIdea: childAdditionalIdea,
                detectedTags: detectedTags,
                isRegenerate: isRegenerate,
                onOpenCollection: onOpenCollection,
                onToast: onToast,
              );
            },
        onRedraw: () {},
        onShowToast: onToast,
      ),
    );
  }

  void _showRecognizedDialog({
    required BuildContext context,
    required AppState appState,
    required AnalyzeDrawingResponse analyzeData,
    VoidCallback? onOpenCollection,
    required void Function(String msg) onToast,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AiRecognitionDialog(
        analyzeData: analyzeData,
        fallbackCharTypes: appState.charTypes,
        onGenerate:
            ({
              required String drawingId,
              required String originalImageUrl,
              required String charTypeId,
              required String charTypeName,
              String? standardizedPrompt,
              String? childAdditionalIdea,
              List<String>? detectedTags,
              bool isRegenerate = false,
            }) {
              executeStage2Generate(
                context: context,
                appState: appState,
                drawingId: drawingId,
                originalImageUrl: originalImageUrl,
                charTypeId: charTypeId,
                charTypeName: charTypeName,
                standardizedPrompt: standardizedPrompt,
                childAdditionalIdea: childAdditionalIdea,
                detectedTags: detectedTags,
                isRegenerate: isRegenerate,
                onOpenCollection: onOpenCollection,
                onToast: onToast,
              );
            },
        onRedraw: () {},
      ),
    );
  }
}
