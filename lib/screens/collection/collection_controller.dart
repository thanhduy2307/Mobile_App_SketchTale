import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/drawing_ai_service.dart';
import '../../services/quiz_service.dart';
import '../../state/app_state.dart';
import '../../utils/app_config.dart';

/// 🧠 Controller Quản Lý Logic Tủ Đồ Của Bé (CollectionController)
/// Tương đương React Hook `useCollectionScreen`:
/// Quản lý chuyển tab (Nhân vật, Truyện đã đọc, Thành tích),
/// Tải lịch sử credit, lịch sử đố vui và đồng bộ dữ liệu hồ sơ với Backend.
class CollectionController extends ChangeNotifier {
  int activeSegment = 0; // 0: Nhân vật 3D, 1: Truyện đã đọc, 2: Thành tích & Hồ sơ
  bool isRefreshing = false;
  List<ReadingLogQuizSummary> quizHistory = [];
  bool isLoadingQuizHistory = false;
  List<CreditTransactionLog> creditLogs = [];
  bool isLoadingCreditLogs = false;

  void setSegment(int index) {
    if (activeSegment == index) return;
    activeSegment = index;
    notifyListeners();
  }

  Future<void> loadCreditLogs(String? token) async {
    isLoadingCreditLogs = true;
    notifyListeners();

    try {
      final logs = await DrawingAiService.fetchCreditTransactionLogs(
        token: token,
      );
      creditLogs = logs;
    } catch (_) {
    } finally {
      isLoadingCreditLogs = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizHistory(String? childId, String? token) async {
    if (!AppConfig.isValidUuid(childId)) return;

    isLoadingQuizHistory = true;
    notifyListeners();

    try {
      final history = await QuizService.fetchChildQuizHistory(
        childId!,
        token: token,
      );
      quizHistory = history;
    } catch (_) {
    } finally {
      isLoadingQuizHistory = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile(
    AppState appState, {
    void Function(String msg)? onToast,
  }) async {
    isRefreshing = true;
    notifyListeners();

    await Future.wait([
      appState.fetchChildProfiles(),
      appState.fetchUserProfile(),
      appState.reloadUserLocalData(),
    ]);

    final childId = appState.activeChildProfile?.id;
    await Future.wait([
      loadQuizHistory(childId, appState.authToken),
      loadCreditLogs(appState.authToken),
      appState.syncCompletedStoriesFromBackend(),
    ]);

    isRefreshing = false;
    notifyListeners();

    onToast?.call('Đã cập nhật dữ liệu mới nhất từ Ba Mẹ.');
  }
}

