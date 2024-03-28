import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:s_state/s_state.dart';

class IFilePickerItem {
  final File file;
  final bool isDocument;
  late Uint8List bytes;

  IFilePickerItem({required this.file, required this.isDocument}) {
    bytes = file.readAsBytesSync();
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

  void uploadSelected() async {
    var selectedItems = selectedPhotos.valueOrNull ?? [];
    var photos = await Future.wait(selectedItems.map((e) => e.getFile()));
    Get.back();
    onSelected?.call(photos.map((e) => IFilePickerItem(file: e, isDocument: false)).toList());
  }

  void onSelectCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (photo != null) {
      Get.back();
      onSelected?.call([IFilePickerItem(file: File(photo.path), isDocument: false)]);
    }
  }

  void onSelectGallery() async {
    var selectedItems = selectedPhotos.valueOrNull ?? [];
    if (selectedItems.isNotEmpty) {
      uploadSelected();
    } else {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 50);
      if (images.isNotEmpty) {
        var photos = images.map((e) => IFilePickerItem(file: File(e.path), isDocument: false)).toList();
        Get.back();
        onSelected?.call(photos);
      }
    }
  }

  void onSelectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result?.files.isNotEmpty ?? false) {
      var files = result!.files.map((e) => IFilePickerItem(file: File(e.path!), isDocument: true)).toList();

      Get.back();
      onSelected?.call(files);
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
