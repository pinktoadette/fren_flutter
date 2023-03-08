import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';


//@todo remove scope model to getX
class UserController extends GetxController {
  late Rx<User> _user;
  User get user => _user.value;
  set user(User value) => _user.value = value;

  void setUser(User user) {
    print ("setUser");
    _user = user.obs;
    print (_user.value.userId);
  }


}