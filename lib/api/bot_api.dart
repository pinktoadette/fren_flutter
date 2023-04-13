import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/constants/constants.dart';

class BotApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;

  /// get inital frankie
  Future getInitialFrankie() async {
    QuerySnapshot<Map<String, dynamic>> data =
        await _firestore.collection(C_BOT_WALKTHRU).orderBy('sequence').get();
    List steps = [];
    for (var element in data.docs) {
      final ele = element.data();
      steps.add(ele);
    }
    return steps;
  }
}
