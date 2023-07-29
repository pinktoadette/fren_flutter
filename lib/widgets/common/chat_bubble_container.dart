import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/chat_bubble.dart';

class StoryBubble extends StatelessWidget {
  final bool isRight;
  final Widget widget;
  final Size size;

  const StoryBubble(
      {Key? key,
      required this.isRight,
      required this.widget,
      required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isRight ? Alignment.bottomRight : Alignment.bottomLeft,
      child: CustomPaint(
          painter: Bubble(isRight),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: widget),
          )),
    );
  }
}
