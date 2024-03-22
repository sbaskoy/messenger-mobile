import 'package:shared_preferences/shared_preferences.dart';

enum LocalManagerKey {
  username,
  password,
  isLogged,
  accessToken,
}

class LocalManager {
  SharedPreferences? pref;
  Future<void> load() async {
    pref = await SharedPreferences.getInstance();
  }

  String getString(LocalManagerKey key) {
    return pref?.getString(key.toString()) ?? "";
  }

  Future<bool> setString(LocalManagerKey key, String value) async {
    return await pref?.setString(key.toString(), value) ?? false;
  }

  bool getBool(LocalManagerKey key) {
    return pref?.getBool(key.toString()) ?? false;
  }

  Future<bool> setBool(LocalManagerKey key, bool value) async {
    return await pref?.setBool(key.toString(), value) ?? false;
  }
}
