import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/app_screen_background.dart';
import 'collection_screen.dart';

/// ChildProfileScreen giờ chuyển tiếp vào CollectionScreen (Góc Của Bé)
/// để loại bỏ màn hình trùng lặp và giữ trải nghiệm liền mạch cho bé.
class ChildProfileScreen extends StatelessWidget {
  final AppState appState;

  const ChildProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return AppScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Góc Của Bé'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: CollectionScreen(
          appState: appState,
          onOpenDrawing: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

