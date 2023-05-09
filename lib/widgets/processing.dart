import 'package:machi_app/widgets/animations/loader.dart';
import 'package:flutter/material.dart';

class Processing extends StatelessWidget {
  final String? text;

  const Processing({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Frankloader(),
        ],
      ),
    );
  }
}
