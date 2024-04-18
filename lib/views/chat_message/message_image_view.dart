import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brand_palettes/gradients.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/controllers/message_controller.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/views/chat_message/edit_image_widget.dart';
import 'package:planner_messenger/widgets/buttons/custom_icon_button.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:math' as math;

import '../../dialogs/file_select/file_select_dialog_controller.dart';

class MessageFilesView extends StatefulWidget {
  final List<IFilePickerItem> files;
  final MessageController? controller;
  const MessageFilesView({super.key, required this.files, this.controller});

  @override
  State<MessageFilesView> createState() => _MessageFilesViewState();
}

class _MessageFilesViewState extends State<MessageFilesView> {
  late final List<IFilePickerItem> _items = widget.files;
  int _selectedIndex = 0;
  bool _editMode = false;
  double _penSize = 3;

  @override
  void initState() {
    super.initState();
    AppUtils.clearTempDirectory();
  }

  Color _penColor = Colors.blue;
  void _send() {
    widget.controller?.sendMessage(attachments: _items);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              allowImplicitScrolling: true,
              physics: _editMode ? const NeverScrollableScrollPhysics() : null,
              itemCount: _items.length,
              onPageChanged: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
              itemBuilder: (context, index) {
                var item = _items[index];
                if (item.isDocument) {
                  return const Center(
                    child: Icon(
                      Icons.insert_drive_file,
                      size: 50,
                    ),
                  );
                }
                return Center(
                  child: AnimatedCrossFade(
                    duration: Durations.medium4,
                    firstChild: EditImageWidget(
                      item: item,
                      color: _penColor,
                      size: _penSize,
                      editMode: _editMode,
                      onColorChanged: (color) {
                        setState(() {
                          _penColor = color;
                        });
                      },
                      onSizeChanged: (size) {
                        setState(() {
                          _penSize = size;
                        });
                      },
                      onDone: (data) {
                        if (mounted) {
                          setState(() {
                            item.bytes = data;
                            item.updateOrCreateTemp();
                            _editMode = false;
                          });
                        }
                      },
                    ),
                    secondChild: Image.file(item.tempFile ?? item.file),
                    crossFadeState: _editMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  ),
                );
              },
            ),
            AnimatedPositioned(
                duration: Durations.medium3,
                top: _editMode ? -10 : 20,
                left: 10,
                right: 10,
                child: AnimatedOpacity(
                  duration: Durations.medium3,
                  opacity: _editMode ? 0 : 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IgnorePointer(
                        ignoring: _editMode,
                        child: CustomIconButton(
                          color: context.theme.disabledColor.withOpacity(0.2),
                          icon: Icons.close,
                          onPressed: Get.back,
                        ),
                      ),
                      if (!widget.files.first.isDocument)
                        CustomIconButton(
                          color: _editMode ? _penColor : context.theme.disabledColor.withOpacity(0.2),
                          icon: Icons.edit,
                          onPressed: () => setState(() {
                            _editMode = true;
                          }),
                        ),
                    ],
                  ),
                )),
            AnimatedPositioned(
              duration: Durations.medium3,
              bottom: _editMode ? -100 : 10,
              left: 10,
              right: 10,
              child: _sendImageTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendImageTab() {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            itemCount: _items.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var item = _items[index];
              if (item.isDocument) {
                return const Center(child: Icon(Icons.edit_document));
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        FadeInImage(
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: MemoryImage(kTransparentImage),
                          image: FileImage(item.file),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 500),
                          firstChild: const Icon(Icons.delete),
                          secondChild: const SizedBox(
                            width: 20,
                            height: 20,
                          ),
                          crossFadeState:
                              _selectedIndex == index ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: CupertinoTextField(
                  onSubmitted: (value) => _send(),
                  controller: widget.controller?.messageTextController,
                  placeholder: "Write a message ....",
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => _send(),
              child: Container(
                // padding: const EdgeInsets.all(8),
                height: 35,
                width: 35,
                decoration: BoxDecoration(color: context.theme.primaryColor, shape: BoxShape.circle),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class VerticalColorPicker extends StatefulWidget {
  final Function(Color color)? onChanged;
  const VerticalColorPicker({super.key, required this.onChanged});

  @override
  State<VerticalColorPicker> createState() => _VerticalColorPickerState();
}

class _VerticalColorPickerState extends State<VerticalColorPicker> {
  static final _googleGrad = const GoogleGrad().colors;
  final _height = 300.0;
  Offset lastOffset = const Offset(0, 0);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        Color selectedColor = _googleGrad[(lastOffset.dy / _height * (_googleGrad.length - 1)).round()];
        widget.onChanged?.call(selectedColor);
        setState(() {
          lastOffset = details.localPosition;
        });
      },
      child: Container(
        width: 10,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: _googleGrad,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: math.min(_height - 10, math.max(0, lastOffset.dy)),
              left: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
