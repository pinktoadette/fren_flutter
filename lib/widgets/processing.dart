import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';

class Processing extends StatelessWidget {
  final String? text;

  const Processing({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Frankloader(),
          // const SizedBox(height: 10),
          // Text(text ?? i18n.translate("processing"), style: const TextStyle(fontSize: 18,
          // fontWeight: FontWeight.w500)),
          // const SizedBox(height: 5),
          // Text(i18n.translate("please_wait"), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
