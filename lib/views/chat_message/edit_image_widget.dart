import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'dart:ui' as ui;
import "dart:math" as math;

import '../../widgets/buttons/custom_icon_button.dart';
import 'message_image_view.dart';

class EditorItem {
  final List<Offset> points;
  final double size;
  final Color color;

  EditorItem({required this.points, required this.size, required this.color});
}

Future<Uint8List?> saveImageFromCustomPainter(CustomPainter painter, Size imageSize, Size screenSize) async {
  double imageWidth = imageSize.width.toDouble();
  double imageHeight = imageSize.height.toDouble();

  // Painter üzerindeki noktaları resim boyutlarıyla çarpma işlemi
  List<EditorItem> updatedPoints = [];
  for (EditorItem item in (painter as ImageEditor).points) {
    List<Offset> scaledPoints = [];

    for (Offset offset in item.points) {
      double scaledX = offset.dx * imageWidth / screenSize.width;
      double scaledY = offset.dy * imageHeight / screenSize.height;
      scaledPoints.add(Offset(scaledX, scaledY));
    }
    updatedPoints.add(EditorItem(
      color: item.color,
      size: item.size * imageWidth / screenSize.width,
      points: scaledPoints,
    ));
  }

  var imagePainter = ImageEditor(image: painter.image);
  imagePainter.points = updatedPoints;
  // painter.points = updatedPoints;

  ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas canvas = Canvas(recorder);
  imagePainter.paint(canvas, imageSize);

  ui.Picture picture = recorder.endRecording();
  ui.Image img = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());

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
  final bool editMode;
  final Function(Uint8List data)? onDone;
  final Function(double size)? onSizeChanged;
  final Function(Color color)? onColorChanged;
  const EditImageWidget({
    super.key,
    required this.item,
    this.size = 3,
    this.color = Colors.black,
    this.onDone,
    required this.editMode,
    this.onSizeChanged,
    this.onColorChanged,
  });

  @override
  State<EditImageWidget> createState() => _EditImageWidgetState();
}

class _EditImageWidgetState extends State<EditImageWidget> {
  ui.Image? image;
  ImageEditor? editor;
  bool isImageloaded = false;
  final GlobalKey _myCanvasKey = GlobalKey();
  List<EditorItem> items = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void _save() async {
    if (widget.onDone != null && editor != null && image != null) {
      AppProgressController.show();
      var data = await saveImageFromCustomPainter(
        editor!,
        Size(image!.width.toDouble(), image!.height.toDouble()),
        Get.size,
      );
      AppProgressController.hide();
      if (data != null) {
        widget.onDone?.call(data);
      }
    }
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
      editor = ImageEditor(
        image: image!,
        defaultPoints: items,
      );
      return GestureDetector(
        onPanDown: (detailData) {
          var lastItem = EditorItem(points: [], size: widget.size, color: widget.color);
          editor!.points.add(lastItem);
          items = editor!.points;

          editor!.update(detailData.localPosition);
          _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
        },
        onPanUpdate: (detailData) {
          editor!.update(detailData.localPosition);
          _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
        },
        onPanEnd: (details) async {},
        child: CustomPaint(
          size: Size(Get.width, Get.height),
          key: _myCanvasKey,
          painter: editor,
          //  child: Image.memory(widget.item.bytes),
        ),
      );
    } else {
      return const Center(child: Text('loading'));
    }
  }

  void _takeBack() {
    if (items.isNotEmpty) {
      items.removeLast();
      editor?.takeBack();
      _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildImage(),
        Positioned(
          top: 20,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _save(),
                child: const Text("Done"),
              ),
              Wrap(
                spacing: 5,
                children: [
                  CustomIconButton(
                      color: context.theme.disabledColor.withOpacity(0.2), icon: Icons.undo, onPressed: _takeBack),
                  CustomIconButton(color: widget.color, icon: Icons.edit, onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 80,
          right: 25,
          child: VerticalColorPicker(
            onChanged: (color) {
              widget.onColorChanged?.call(color);
            },
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomIconButton(
                  color: widget.size == 3 ? context.theme.disabledColor.withOpacity(0.5) : null,
                  icon: Icons.thirteen_mp,
                  onPressed: () {
                    widget.onSizeChanged?.call(3);
                  }),
              CustomIconButton(
                  color: widget.size == 5 ? context.theme.disabledColor.withOpacity(0.5) : null,
                  icon: Icons.thirteen_mp,
                  onPressed: () {
                    widget.onSizeChanged?.call(5);
                  }),
              CustomIconButton(
                  color: widget.size == 7 ? context.theme.disabledColor.withOpacity(0.5) : null,
                  icon: Icons.thirteen_mp,
                  onPressed: () {
                    widget.onSizeChanged?.call(7);
                  }),
            ],
          ),
        )
      ],
    );
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

  void takeBack() {
    if (points.isNotEmpty) {
      points.removeLast();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var width = math.min(size.width, image.width);

    var scaleRate = 100 - (100 * width) / image.width;
    var height = image.height - (image.height * (scaleRate / 100));
    var xOffset = (size.width - width) / 2;
    var yOffset = (size.height - height) / 2;

    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(xOffset, yOffset, width.toDouble(), height.toDouble());

    canvas.drawImageRect(image, src, dst, Paint());

    for (EditorItem item in points) {
      Paint painter = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill
        ..strokeWidth = item.size;
      // for (Offset offset in item.points) {
      //   double scaledX = offset.dx;
      //   double scaledY = offset.dy;
      //   //canvas.drawCircle(Offset(scaledX, scaledY), item.size, painter);
      //   if (points[i] != null && points[i + 1] != null) {
      //     canvas.drawLine(points[i], points[i + 1], paint);
      //   } else if (points[i] != null && points[i + 1] == null) {
      //     // Eğer bir noktanın sonraki noktası null ise, bu kaldırma işareti
      //     // olduğu için noktanın yerine küçük bir daire çizilir.
      //     canvas.drawCircle(points[i]!, 2.5, paint);
      //   }
      // }
      for (int i = 0; i < item.points.length - 1; i++) {
        if (i < item.points.length) {
          canvas.drawLine(item.points[i], item.points[i + 1], painter);
        } else if (i >= item.points.length) {
          canvas.drawCircle(item.points[i], item.size, painter);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return image != (oldDelegate as ImageEditor).image;
  }
}
