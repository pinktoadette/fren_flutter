import 'package:fren_app/constants/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

class BotTimer extends StatefulWidget {
  final double percent;
  const BotTimer({Key? key, required this.percent}) : super(key: key);

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
      percent: widget.percent,
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
