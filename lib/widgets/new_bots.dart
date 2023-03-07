import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NewBotWidget extends StatelessWidget {
  const NewBotWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      height: 80.0,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 80.0,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/default%2FCapture.PNG?alt=media&token=5197b06d-df5f-435a-87c3-d0af2c07dce5'),
              radius: 80,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            width: 80.0,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/default%2FCapture.PNG?alt=media&token=5197b06d-df5f-435a-87c3-d0af2c07dce5'),
              radius: 80,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            width: 80.0,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/default%2FCapture.PNG?alt=media&token=5197b06d-df5f-435a-87c3-d0af2c07dce5'),
              radius: 80,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            width: 80.0,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/default%2FCapture.PNG?alt=media&token=5197b06d-df5f-435a-87c3-d0af2c07dce5'),
              radius: 80,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            width: 80.0,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/default%2FCapture.PNG?alt=media&token=5197b06d-df5f-435a-87c3-d0af2c07dce5'),
              radius: 80,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            width: 80.0,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/default%2FCapture.PNG?alt=media&token=5197b06d-df5f-435a-87c3-d0af2c07dce5'),
              radius: 80,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}