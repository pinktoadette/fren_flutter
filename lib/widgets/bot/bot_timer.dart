import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/widgets/bot/tiny_bot.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

class BotTimer extends StatefulWidget {
  const BotTimer({Key? key}) : super(key: key);

  @override
  _BotTimerState createState() => _BotTimerState();
}

class _BotTimerState extends State<BotTimer> {
  @override
  Widget build(BuildContext context) {
    /// Initialization

    return CircularPercentIndicator(
      radius: 10.0,
      lineWidth: 10.0,
      percent: 0.8,
      center: const TinyBotIcon(image: 'assets/images/faces/2.png'),
      backgroundColor: Theme.of(context).primaryColor,
      progressColor: APP_ACCENT_COLOR,
    );
  }
}
