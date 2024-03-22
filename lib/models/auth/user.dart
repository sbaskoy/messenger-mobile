class User {
  int? id;
  String? email;
  String? username;
  int? banned;
  String? photo;
  String? fullName;
  int? tenantId;

  User({this.id, this.email, this.username, this.banned, this.photo});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    username = json['username'];
    banned = json['banned'];
    photo = json['photo'];
    fullName = json['full_name'];
    tenantId = json['tenant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['username'] = username;
    data['banned'] = banned;
    data['photo'] = photo;
    return data;
  }

  String? getPhotoUrl() {
    return photo?.replaceAll("viewFile/user_token", "viewImage/$id-$tenantId");
  }
}
