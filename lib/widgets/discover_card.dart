import 'package:machi_app/widgets/animations/loader.dart';
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
      color: Colors.black,
      child: SizedBox(
        height: screenHeight - 200,
        width: screenWidth,
        child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset('assets/images/face.jpg', width: screenWidth),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(subtitle),
                      const SizedBox(height: 50),
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
