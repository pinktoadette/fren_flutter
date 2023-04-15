import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/widgets/chat/typing_indicator.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:iconsax/iconsax.dart';

class CustomHeaderInputWidget extends StatefulWidget {
  final Function(dynamic data) notifyParent;

  final bool? isBotTyping;
  final types.PartialImage? attachmentPreview;
  const CustomHeaderInputWidget(
      {super.key,
      required this.notifyParent,
      this.isBotTyping,
      this.attachmentPreview});

  @override
  _CustomHeaderInputWidgetState createState() =>
      _CustomHeaderInputWidgetState();
}

class _CustomHeaderInputWidgetState extends State<CustomHeaderInputWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [_showHeader(context)]);
  }

  Widget _showHeader(BuildContext context) {
    if (widget.isBotTyping == true) {
      return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: JumpingDots(color: Theme.of(context).colorScheme.primary),
          ));
    } else if (widget.attachmentPreview?.uri != null) {
      return Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                height: 80,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Image border
                    child: SizedBox.fromSize(
                        size: const Size.fromRadius(48), // Image radius
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: Image.file(
                            File(widget.attachmentPreview!.uri),
                            fit: BoxFit.fitHeight,
                            width: 80,
                            height: 80,
                          ),
                        ))),
              )),
          Positioned(
            top: 0,
            right: 5,
            child: GestureDetector(
              onTap: () {
                widget.notifyParent({'image': null});
              },
              child: const Icon(Iconsax.close_circle),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
