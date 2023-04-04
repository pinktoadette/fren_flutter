import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';

class Processing extends StatelessWidget {
  final String? text;

  const Processing({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Frankloader(),
        ],
      ),
    );
  }
}
