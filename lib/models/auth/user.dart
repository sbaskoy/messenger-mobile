class User {
  int? id;
  String? email;
  String? username;
  int? banned;
  String? photo;
  String? fullName;
  int? tenantId;

  User({this.id, this.email, this.username, this.banned, this.photo});

  User.fromJson(json) {
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
    data['full_name'] = fullName;
    data['tenant_id'] = tenantId;
    return data;
  }

  String? getPhotoUrl() {
    return photo?.replaceAll("viewFile/user_token", "viewImage/$id-$tenantId");
  }
}

class GroupCallUser {
  User? user;
  bool? isOwner;
  GroupCallUser({this.isOwner, this.user});
  GroupCallUser.fromJson(mapData) {
    user = User.fromJson(mapData["user"]);
    isOwner = mapData["isOwner"] ?? false;
  }
}
