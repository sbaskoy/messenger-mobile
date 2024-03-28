import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'dart:ui' as ui;

class EditorItem {
  final List<Offset> points;
  final double size;
  final Color color;

  EditorItem({required this.points, required this.size, required this.color});
}

Future<Uint8List?> saveImageFromCustomPainter(CustomPainter painter, Size size) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas canvas = Canvas(recorder);
  painter.paint(canvas, size);

  ui.Picture picture = recorder.endRecording();
  ui.Image img = await picture.toImage(size.width.toInt(), size.height.toInt());

  ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    Uint8List bytes = byteData.buffer.asUint8List();
    return bytes;
  }
  return null;
}

class EditImageWidget extends StatefulWidget {
  final IFilePickerItem item;
  final double size;
  final Color color;
  final Function(Uint8List data)? onUpdate;
  const EditImageWidget({super.key, required this.item, this.size = 3, this.color = Colors.black, this.onUpdate});

  @override
  State<EditImageWidget> createState() => _EditImageWidgetState();
}

class _EditImageWidgetState extends State<EditImageWidget> {
  ui.Image? image;
  bool isImageloaded = false;
  final GlobalKey _myCanvasKey = GlobalKey();
  List<EditorItem> items = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    image = await loadImage();
  }

  Future<ui.Image> loadImage() async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(widget.item.bytes, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (isImageloaded) {
      ImageEditor editor = ImageEditor(
        image: image!,
        defaultPoints: items,
      );
      return GestureDetector(
        onPanDown: (detailData) {
          var lastItem = EditorItem(points: [], size: widget.size, color: widget.color);
          editor.points.add(lastItem);
          items = editor.points;

          editor.update(detailData.localPosition);
          _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
        },
        onPanUpdate: (detailData) {
          editor.update(detailData.localPosition);
          _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
        },
        onPanEnd: (details) async {
          if (widget.onUpdate != null) {
            var data =
                await saveImageFromCustomPainter(editor, Size(image!.width.toDouble(), image!.height.toDouble()));
            if (data != null) {
              widget.onUpdate?.call(data);
            }
          }
        },
        child: CustomPaint(
          key: _myCanvasKey,
          painter: editor,
        ),
      );
    } else {
      return const Center(child: Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }
}

class ImageEditor extends CustomPainter {
  ImageEditor({required this.image, List<EditorItem>? defaultPoints}) {
    if (defaultPoints != null) {
      points = defaultPoints;
    }
  }

  final ui.Image image;

  List<EditorItem> points = [];

  void update(Offset offset) {
    points.last.points.add(offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());

    for (EditorItem item in points) {
      Paint painter = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;
      for (Offset offset in item.points) {
        // Ölçeklenmiş koordinatlara dikkat edin
        double scaledX = offset.dx; // * size.width / image.width.toDouble();
        double scaledY = offset.dy; // * size.height / image.height.toDouble();
        canvas.drawCircle(Offset(scaledX, scaledY), item.size, painter);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return image != (oldDelegate as ImageEditor).image;
  }
}
