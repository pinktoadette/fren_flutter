import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class ReportApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${PY_API}report";
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<void> reportContent(
      {required itemId,
      required itemType,
      required reason,
      required comments}) async {
    String url = '$baseUri/report';
    try {
      final dio = await auth.getDio();
      await dio.post(url, data: {
        REPORT_ITEM_ID: itemId,
        REPORT_ITEM_TYPE: itemType,
        REPORT_REASON: reason,
        REPORT_COMMENTS: comments
      });
    } catch (err) {
      rethrow;
    }
  }
}
