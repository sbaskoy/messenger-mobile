import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  ImageUtils._();
  static Future<Uint8List> compressImageWithByte(Uint8List bytes, {int? quality}) async {
    Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 800,
      minWidth: 1000,
      quality: quality ?? 50,
    );
    return compressedBytes;
  }

  static Future<Uint8List> compressImageWithFile(String path, {int? quality}) async {
    Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
      path,
      minHeight: 800,
      minWidth: 1000,
      quality: quality ?? 50,
    );
    if (compressedBytes == null) {
      throw "Compress error File not found or file not image file";
    }
    return compressedBytes;
  }
}
