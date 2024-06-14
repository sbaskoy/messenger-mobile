import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:planner_messenger/utils/image_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

class IFilePickerItem {
  //final File file;
  final bool isDocument;
  final String originalPath;
  late Uint8List bytes;
  String? name;

  IFilePickerItem({required this.bytes, required this.isDocument, required this.originalPath, this.name}) {
    //bytes = file.readAsBytesSync();
  }
}

class FileSelectDialogController {
  final photos = SState<List<Medium>>([]);
  final selectedPhotos = SState<List<Medium>>([]);
  final void Function(List<IFilePickerItem> selected)? onSelected;
  FileSelectDialogController({this.onSelected});
  Future<void> loadAlbums() async {
    if (!await _promptPermissionSetting()) return;
    final List<Album> imageAlbums = await PhotoGallery.listAlbums();
    var allPhotoAlbum = imageAlbums.firstWhereOrNull((element) => element.id == "__ALL__");
    if (allPhotoAlbum == null) return;
    final MediaPage imagePage = await allPhotoAlbum.listMedia();
    final List<Medium> allMedia = [...imagePage.items];
    photos.setState(allMedia.take(10).toList());
  }

  void togglePhoto(Medium photo) {
    var selectedItems = selectedPhotos.valueOrNull ?? [];
    if (selectedItems.any((element) => element.id == photo.id)) {
      selectedItems.removeWhere((element) => element.id == photo.id);
    } else {
      selectedItems.add(photo);
    }
    selectedPhotos.setState(selectedItems);
  }

  // void uploadSelected() async {
  //   var selectedItems = selectedPhotos.valueOrNull ?? [];
  //   var photos = await Future.wait(selectedItems.map((e) => e.getFile()));
  //   Get.back();
  //   onSelected?.call(photos.map((e) => IFilePickerItem(file: e, isDocument: false)).toList());
  // }

  static Future<IFilePickerItem?> selectPhotoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      AppProgressController.show();
      if (photo != null) {
        var bytes = await ImageUtils.compressImageWithFile(photo.path);
        return IFilePickerItem(bytes: bytes, isDocument: false, originalPath: photo.path, name: photo.name);
      }
      return null;
    } finally {
      AppProgressController.hide();
    }
  }

  void onSelectCamera() async {
    final IFilePickerItem? photo = await selectPhotoFromCamera();
    if (photo != null) {
      Get.back();
      onSelected?.call([photo]);
    }
  }

  void onSelectGallery() async {
    var selectedItems = selectedPhotos.valueOrNull ?? [];
    if (selectedItems.isNotEmpty) {
      // uploadSelected();
    } else {
      try {
        final ImagePicker picker = ImagePicker();
        final List<XFile> images = await picker.pickMultiImage(imageQuality: 50, limit: 20);
        if (images.isNotEmpty) {
          AppProgressController.show();
          List<IFilePickerItem> photos = [];
          for (var image in images) {
            var bytes = await ImageUtils.compressImageWithFile(image.path);
            photos.add(IFilePickerItem(bytes: bytes, isDocument: false, originalPath: image.path, name: image.name));
          }
          Get.back();
          onSelected?.call(photos);
        }
      } finally {
        AppProgressController.hide();
      }
    }
  }

  void onSelectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result?.files.isNotEmpty ?? false) {
        AppProgressController.show();
        List<IFilePickerItem> files = [];
        for (var file in result!.files) {
          var bytes = await File(file.path!).readAsBytes();
          files.add(IFilePickerItem(bytes: bytes, isDocument: true, originalPath: file.path!, name: file.name));
        }
        Get.back();
        onSelected?.call(files);
      }
    } finally {
      AppProgressController.hide();
    }
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted && await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }
}
