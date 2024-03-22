class ApiInfoModel<T> {
  String? status;
  String? message;
  T? data;

  ApiInfoModel({required this.status, required this.message, required this.data});

  ApiInfoModel.fromJson(json) {
    status = json["code"];
    message = json["message"];
  }
}
