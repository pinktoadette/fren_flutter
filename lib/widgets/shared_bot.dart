import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ShareBotWidget extends StatelessWidget {
  const ShareBotWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //Added the color here
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
        physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: 3,
          itemBuilder: (context, int index) {
          return Container(
            height: 100,
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 24),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
              color: const Color(0xff131200).withOpacity(0.20),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(
              3, 3), // changes position of shadow
            ),
        ],
        ),
        );
    }));
  }
}