import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lottie/lottie.dart';

class ActivityWidget extends StatefulWidget {
  @override
  _ActivityWidgetState createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  static const _pageSize = 20;


  @override
  Widget build(BuildContext context) {
    return Container(
      //Added the color here
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
        physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: 10,
          itemBuilder: (context, int index) {
          return Container(
            height: 100,
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 24),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
              color: const Color(0xff131200).withOpacity(0.20),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(
              3, 3), // changes position of shadow
            ),
        ],
        ),
        );
    }));
  }
}