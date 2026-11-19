// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';

import 'image_picker_helper.dart';

Future<PickedImageFile?> pickImageFromDeviceImpl() async {
  final completer = Completer<PickedImageFile?>();
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.onLoadEnd.listen((e) {
        if (reader.result != null) {
          final bytes = reader.result as Uint8List;
          if (!completer.isCompleted) {
            completer.complete(
              PickedImageFile(bytes: bytes, fileName: file.name),
            );
          }
        } else {
          if (!completer.isCompleted) completer.complete(null);
        }
      });
      reader.readAsArrayBuffer(file);
    } else {
      if (!completer.isCompleted) completer.complete(null);
    }
  });

  return completer.future;
}

