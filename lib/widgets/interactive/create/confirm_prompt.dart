// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/datas/interactive.dart';

class ConfirmPrompt extends StatelessWidget {
  final CreateNewInteractive post;
  final ValueChanged<bool> onConfirm;

  const ConfirmPrompt({
    super.key,
    required this.post,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Card(
          color: Color(int.parse("0xFF${post.theme.backgroundColor}")),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: size.height * 0.8 - 100,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Title Auto Generated",
                    style: TextStyle(
                        color:
                            Color(int.parse("0xFF${post.theme.titleColor}")))),
                Text(post.prompt,
                    style: TextStyle(
                        color:
                            Color(int.parse("0xFF${post.theme.textColor}")))),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Lottie.asset(
                    'assets/lottie/emoji/cool_emoji.json',
                    width: 200,
                    height: 200,
                  ),
                )
              ],
            )),
          ),
        ));
  }
}
