import 'package:get/get.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/models/user_model.dart';

class UserController extends GetxController {
  Rx<User?> _user = (null).obs;

  User? get user => _user.value;
  set user(User? value) =>
      _user.value = value!; // Assuming you want to ensure non-null values here

  void initUser() {
    _user = UserModel().user.obs;
  }
}
