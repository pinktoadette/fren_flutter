import 'package:fren_app/widgets/loader.dart';
import 'package:flutter/material.dart';

class ButtonChanged extends Notification {
  final bool val;
  ButtonChanged(this.val);
}

class DiscoverCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String btnText;
  final bool showFrankie = true;

  const DiscoverCard(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.btnText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      child: SizedBox(
        height: screenHeight - 250,
        width: screenWidth,
        child: Container(
            padding: const EdgeInsets.all(40),
            height: screenHeight * 0.85,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Frankloader(),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(subtitle),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            ButtonChanged(true).dispatch(context);
                          },
                          child: Text(btnText))
                    ],
                  ),
                ])),
      ),
    );
  }
}
