import 'dart:async';
import 'package:machi_app/helpers/date_format.dart';
import 'package:get/get.dart';

class TimerController extends GetxController {
  Timer? _timer;
  int remainingSeconds = 1;
  RxInt time = 0.obs;

  @override
  void onClose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.onClose();
  }

  startTimer(int timestamp) {
    int remainingSeconds = countdown(timestamp);
    Duration duration = const Duration(seconds: 1);

    _timer = Timer.periodic(duration, (Timer timer) {
      if (remainingSeconds == 0) {
        time.value = 0;
        timer.cancel();
      } else {
        time.value = remainingSeconds.toInt();
        remainingSeconds--;
        update();
      }
    });
  }
}
