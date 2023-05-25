import 'package:flutter/material.dart';

// view story board as the creator
class MainControlWidget extends StatefulWidget {
  const MainControlWidget({Key? key}) : super(key: key);

  @override
  _MainControlWidgetState createState() => _MainControlWidgetState();
}

class _MainControlWidgetState extends State<MainControlWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0),
        ),
        height: 70,
        width: width,
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: const Card(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 25),
              Text("Play"),
              SizedBox(width: 25),
            ],
          ),
        ])));
  }
}
