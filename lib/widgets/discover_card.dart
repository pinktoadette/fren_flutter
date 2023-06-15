import 'package:flutter/material.dart';

class ButtonChanged extends Notification {
  final bool val;
  ButtonChanged(this.val);
}

class DiscoverCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final String btnText;
  final bool showFrankie = true;

  const DiscoverCard(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.image,
      required this.btnText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    Size size = MediaQuery.of(context).size;

    return Card(
      color: Colors.black,
      child: SizedBox(
        width: size.width,
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
                      Image.network(image, width: size.width),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(subtitle),
                      const SizedBox(height: 30),
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
