import 'package:get/get.dart';
import 'package:machi_app/datas/user.dart';

class UserController extends GetxController {
  Rx<User?> _user = (null).obs;

  User? get user => _user.value;
  set user(User? value) => _user.value = value;

  void updateUser(User newUser) {
    _user = newUser.obs;
  }
}
