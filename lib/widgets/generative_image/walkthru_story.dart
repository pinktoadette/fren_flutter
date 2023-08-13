import 'dart:async';

import 'package:flutter/material.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';

class WalkThruStory extends StatefulWidget {
  final Story? story;
  final VoidCallback onCarouselCompletion;

  const WalkThruStory(
      {Key? key, required this.onCarouselCompletion, this.story})
      : super(key: key);

  @override
  State<WalkThruStory> createState() => _WalkThruStoryState();
}

class _WalkThruStoryState extends State<WalkThruStory> {
  final List<Script> script = [];

  int currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startCarousel();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startCarousel() {
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 500,
        child: Card(
          surfaceTintColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ));
  }
}
