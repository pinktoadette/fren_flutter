import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/countdown.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

class BotTimer extends StatelessWidget {
  BotTimer({Key? key}) : super(key: key);
  final TimerController timerController = Get.find(tag: 'timer');

  @override
  Widget build(BuildContext context) {
    /// Initialization

    return CircularPercentIndicator(
      radius: 10.0,
      lineWidth: 10.0,
      percent: timerController.remainingSeconds * 1.0,
      center: Icon(
        Iconsax.clock,
        size: 14,
        color: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      progressColor: APP_ACCENT_COLOR,
    );
  }
}
