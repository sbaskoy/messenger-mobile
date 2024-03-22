class FileModel {
  int? fileId;
  String? fileName;
  String? fileExtension;
  int? fileSize;
  int? fileUploader;
  int? projectId;
  int? taskId;
  String? fileLink;

  FileModel(
      {this.fileId,
      this.fileName,
      this.fileExtension,
      this.fileSize,
      this.fileUploader,
      this.projectId,
      this.taskId,
      this.fileLink});

  FileModel.fromJson(Map<String, dynamic> json) {
    fileId = json['file_id'];
    fileName = json['file_name'];
    fileExtension = json['file_extension'];
    fileSize = json['file_size'];
    fileUploader = json['file_uploader'];
    projectId = json['project_id'];
    taskId = json['task_id'];
    fileLink = json['file_link'];
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
}
