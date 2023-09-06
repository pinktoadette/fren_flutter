import 'package:flutter/material.dart';

class StepCounterSignup extends StatelessWidget {
  final int step;

  const StepCounterSignup({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    String text = "Step ${step.toInt()} of 3";
    return Semantics(
        label: text,
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 5, bottom: 10),
          child: Text(text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall),
        ));
  }
}
