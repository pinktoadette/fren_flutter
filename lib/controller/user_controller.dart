import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/sqlite/connection_db.dart';
import 'package:get/get.dart';


//@todo remove scope model to getX
class UserController extends GetxController {
  late Rx<User> _user;
  User get user => _user.value;
  set user(User value) => _user.value = value;

  void setUser(User user) {
    /// homescreen subscribes to user event changes
    /// calls udateUserObject and updates userController (here)
    _user = user.obs;
    updateLocalDB();
  }

  void updateLocalDB() {
    // final DatabaseService db = DatabaseService();

  }

}