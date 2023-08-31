import 'dart:developer';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/interactive.dart';

class InteractiveBoardController extends GetxController implements GetxService {
  Rx<CreateNewInteractive?> createInteractive = Rx<CreateNewInteractive?>(null);

  int offset = 1;
  int limitPage = PAGE_CHAT_LIMIT;

  @override
  void onInit() async {
    log("Interactive board initialized");
    super.onInit();
  }

  void createUpdate(CreateNewInteractive object) {
    createInteractive.value = object;
  }

  void clearCreate() {
    createInteractive.value = null;
  }
}
