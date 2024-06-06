import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s_state/s_state.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../utils/app_utils.dart';

class FileModel {
  int? fileId;
  String? fileName;
  String? fileExtension;
  int? fileSize;
  int? fileUploader;
  int? projectId;
  int? taskId;
  String? fileLink;
  String? createdAt;

  FileModel({
    this.fileId,
    this.fileName,
    this.fileExtension,
    this.fileSize,
    this.fileUploader,
    this.projectId,
    this.taskId,
    this.fileLink,
    this.createdAt,
  });

  FileModel.fromJson(Map json) {
    fileId = json['file_id'];
    fileName = json['file_name'];
    fileExtension = json['file_extension'];
    fileSize = json['file_size'];
    fileUploader = json['file_uploader'];
    projectId = json['project_id'];
    taskId = json['task_id'];
    fileLink = json['file_link'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_id'] = fileId;
    data['file_name'] = fileName;
    data['file_extension'] = fileExtension;
    data['file_size'] = fileSize;
    data['file_uploader'] = fileUploader;
    data['project_id'] = projectId;
    data['task_id'] = taskId;
    data['file_link'] = fileLink;
    return data;
  }

  String? getUrl() => AppUtils.getImageUrl(fileLink);

  bool isImage() => AppUtils.isImage(fileExtension ?? "");
  String getFileSizeToMb() {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if ((fileSize ?? 0) == 0) return '0${suffixes[0]}';
    var i = (log(fileSize!) / log(1024)).floor();
    return ((fileSize! / pow(1024, i)).toStringAsFixed(0)) + suffixes[i];
  }

  final downloading = SState(false);
  final downloadingPercent = SState(0.0);
  Future<void> open() async {
    var filePath = await download();
    await OpenFilex.open(filePath);
  }

  Future<String> download() async {
    downloading.setState(true);
    String applicationDocumentPath = (await getApplicationCacheDirectory()).path;
    var filePath = path.join(applicationDocumentPath, "contents", "$fileId.$fileExtension");

    if (await File(filePath).exists()) {
      downloading.setState(false);

      return filePath;
    }
    var isExistsFolder = await Directory(path.join(applicationDocumentPath, "contents")).exists();
    if (!isExistsFolder) {
      await Directory(path.join(applicationDocumentPath, "contents")).create();
    }

    var dio = Dio();
    dio.interceptors.add(LogInterceptor());
    try {
      var response = await dio.get(
        getUrl()!,
        onReceiveProgress: showDownloadProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      var file = File(filePath);

      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      debugPrint(e.toString());
    }

    downloading.setState(false);
    _deleteLastFiles();
    return filePath;
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      downloadingPercent.setState(received / total * 100);
    }
  }

  void _deleteLastFiles() async {
    String applicationDocumentPath = (await getApplicationDocumentsDirectory()).path;
    var directory = Directory(path.join(applicationDocumentPath, "planner_messenger_contents"));
    DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
    if (await directory.exists()) {
      directory.listSync().forEach((file) {
        DateTime fileCreatedDate = (file.statSync()).changed;
        if (fileCreatedDate.isBefore(lastWeek)) {
          file.deleteSync(recursive: true);
        }
      });
    }
  }

  Widget buildLoadingBar({double size = 30.0}) => downloading.builder(
        (loading, data, error, context) {
          if (data == true) {
            return downloadingPercent.builder((loading, data, error, context) {
              return SizedBox(
                width: size,
                height: size,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    startAngle: 270,
                    endAngle: 270,
                    showLabels: false,
                    showTicks: false,
                    radiusFactor: 0.6,
                    axisLineStyle: const AxisLineStyle(
                      cornerStyle: CornerStyle.bothFlat,
                      color: Colors.black12,
                      thickness: 12,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: data ?? 0,
                        cornerStyle: CornerStyle.bothFlat,
                        width: 12,
                        sizeUnit: GaugeSizeUnit.logicalPixel,
                        color: context.theme.primaryColor,
                      ),
                    ],
                  )
                ]),
              );
            });
          }
          return Text(getFileSizeToMb());
        },
      );
}
