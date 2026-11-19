import 'dart:async';
import 'dart:typed_data';

import 'image_picker_helper_stub.dart'
    if (dart.library.html) 'image_picker_helper_web.dart';

class PickedImageFile {
  final Uint8List bytes;
  final String fileName;

  const PickedImageFile({
    required this.bytes,
    required this.fileName,
  });
}

/// Mo hop thoai chon file anh tu may tinh / thiet bi
Future<PickedImageFile?> pickImageFromDevice() => pickImageFromDeviceImpl();

