import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:s_state/s_state.dart';

class FileSelectDialogController {
  final photos = SState<List<Medium>>([]);
  final selectedPhotos = SState<List<Medium>>([]);
  final void Function(List<File> selected)? onSelected;
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
    onSelected?.call(photos);
    Get.back();
  }

  void onSelectCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (photo != null) {
      onSelected?.call([File(photo.path)]);
      Get.back();
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
        var photos = images.map((e) => File(e.path)).toList();
        onSelected?.call(photos);
        Get.back();
      }
    }
  }

  void onSelectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result?.files.isNotEmpty ?? false) {
      var files = result!.files.map((e) => File(e.path!)).toList();

      onSelected?.call(files);
      Get.back();
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
