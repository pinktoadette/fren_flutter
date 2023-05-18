import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:machi_app/widgets/app_logo.dart';

class FrostedAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final bool showLeading;

  const FrostedAppBar(
      {Key? key,
      required this.title,
      required this.actions,
      required this.showLeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      automaticallyImplyLeading: showLeading,
      backgroundColor: Colors.transparent,
      pinned: true,
      floating: false,
      snap: false,
      actions: actions ?? [],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20),
                  child: title,
                ),
              ],
            )),
      ),
    );
  }
}
