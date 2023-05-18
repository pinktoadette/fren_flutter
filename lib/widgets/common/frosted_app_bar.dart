import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final bool showLeading;
  final Widget? leading;

  const FrostedAppBar(
      {Key? key,
      required this.title,
      required this.actions,
      required this.showLeading,
      this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 50,
      automaticallyImplyLeading: showLeading,
      backgroundColor: Colors.transparent,
      leading: leading ?? const SizedBox.shrink(),
      pinned: true,
      floating: false,
      snap: false,
      actions: actions ?? [],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 5),
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
