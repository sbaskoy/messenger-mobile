import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'package:transparent_image/transparent_image.dart';

import 'file_select_dialog_controller.dart';

class FileSelectDialog extends StatefulWidget {
  final void Function(List<File> selected)? onSelected;
  final bool canSelectFile;
  const FileSelectDialog({super.key, this.onSelected, this.canSelectFile = true});

  @override
  State<FileSelectDialog> createState() => _FileSelectDialogState();
}

class _FileSelectDialogState extends State<FileSelectDialog> {
  late final _controller = FileSelectDialogController(onSelected: widget.onSelected);

  @override
  Widget build(BuildContext context) {
    _controller.loadAlbums();
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: _controller.photos.builder((loading, photos, error, context) {
              if (photos?.isNotEmpty ?? false) {
                return _controller.selectedPhotos.builder((loading, selectedPhotos, error, context) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos!.length,
                    itemBuilder: (context, index) {
                      var photo = photos[index];
                      var selected = selectedPhotos?.any((e) => e.id == photo.id) ?? false;
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () => _controller.togglePhoto(photo),
                              child: Container(
                                width: 80,
                                height: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300],
                                ),
                                clipBehavior: Clip.hardEdge,
                                //margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: FadeInImage(
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 75,
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: ThumbnailProvider(
                                    mediumId: photo.id,
                                    mediumType: photo.mediumType,
                                    highQuality: true,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: context.theme.disabledColor.withOpacity(0.5)),
                                    color: selected ? context.theme.primaryColor.withOpacity(0.5) : null,
                                  ),
                                  child: selected
                                      ? Icon(
                                          Icons.done,
                                          color: context.theme.colorScheme.secondary,
                                        )
                                      : null,
                                ))
                          ],
                        ),
                      );
                    },
                  );
                });
              }
              return const SizedBox();
            }),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.theme.disabledColor.withOpacity(0.2),
                ),
              ),
            ),
            child: InkWell(
              onTap: () => _controller.onSelectCamera(),
              child: Row(
                children: [
                  Icon(
                    Icons.camera,
                    size: 40,
                    color: context.theme.disabledColor.withOpacity(0.5),
                  ),
                  const SizedBox(width: 10),
                  const Text("Kameradan seç"),
                ],
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.theme.disabledColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: _controller.selectedPhotos.builder((loading, data, error, context) {
                return InkWell(
                  onTap: () => _controller.onSelectGallery(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        size: 40,
                        color: context.theme.disabledColor.withOpacity(0.5),
                      ),
                      const SizedBox(width: 10),
                      data?.isNotEmpty ?? false
                          ? Text("${data!.length} dosyayı ekle")
                          : const Text(
                              "Galeriden seç",
                            ),
                    ],
                  ),
                );
              })),
          if (widget.canSelectFile)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.theme.disabledColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: InkWell(
                onTap: () => _controller.onSelectFile(),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 40,
                      color: context.theme.disabledColor.withOpacity(0.5),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Dosya seç",
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
