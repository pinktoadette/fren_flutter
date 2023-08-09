import 'package:get_storage/get_storage.dart';

class StorageHelper {
  static final _app = GetStorage();

  bool loadBool(String key) => _app.read(key) ?? false;
  setBool(String key, bool value) => _app.write(key, value);

  void delete(String key) {
    _app.remove(key);
  }
}
