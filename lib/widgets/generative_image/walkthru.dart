import 'dart:async';

import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';

/// Displays screenshots of the app as tutorial.
/// This is displayed when user signs up and needs a profile picture.
class WalkThruSteps extends StatefulWidget {
  final VoidCallback onCarouselCompletion;

  const WalkThruSteps({Key? key, required this.onCarouselCompletion})
      : super(key: key);

  @override
  State<WalkThruSteps> createState() => _WalkThruStepsState();
}

class _WalkThruStepsState extends State<WalkThruSteps> {
  late AppLocalizations _i18n;

  final List<String> pictures = [
    '',
    '',
    'walk1.jpg',
    'walk2.jpg',
    'walk4.jpg',
    'walk5.jpg'
  ];

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  void startCarousel() {
    if (!mounted) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % pictures.length;
        widget.onCarouselCompletion();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 415,
        child: Card(
          surfaceTintColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (pictures[currentIndex] != "")
                Image.asset(
                  "assets/images/walkthru/${pictures[currentIndex]}",
                  fit: BoxFit.cover,
                ),
              if (currentIndex < 2)
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _i18n.translate("walkthru_${currentIndex + 1}"),
                    style: const TextStyle(fontSize: 20),
                  ),
                ))
              else
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _i18n.translate("walkthru_${currentIndex + 1}"),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
            ],
          ),
        ));
  }
}
