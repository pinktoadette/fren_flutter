import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';

//@todo remove scope model to getX
class UserController extends GetxController {
  late Rx<User> _user;
  late Rx<String> _idToken;

  User get user => _user.value;
  set user(User value) => _user.value = value;

  String get idToken => _idToken.value;
  set idToken(String value) => _idToken.value = value;

  setIdToken(String token) {
    _idToken = token.obs;
  }

  @override
  void onInit() async {
    initUser();
    super.onInit();
  }

  void initUser() {
    _user = UserModel().user.obs;
  }
}
