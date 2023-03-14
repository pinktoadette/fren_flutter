
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class ErrorLoggedApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<void> postError({
    required errorMessage,
    required errorLocation
  }) async {
    String url = '$baseUri/error/logs';
    final dio = await auth.getDio();
    await dio.post(url, data: { "message": errorMessage, "location": errorLocation });

  }

}