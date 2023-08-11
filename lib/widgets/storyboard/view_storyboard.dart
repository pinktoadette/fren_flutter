import 'dart:typed_data';

import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// view story board as the creator
class ViewStoryboard extends StatefulWidget {
  final bool showName;
  const ViewStoryboard({Key? key, this.showName = false}) : super(key: key);

  @override
  State<ViewStoryboard> createState() => _ViewStoryboardState();
}

class _ViewStoryboardState extends State<ViewStoryboard> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  Uint8List? bytes;
  late Story story;

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
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            storyboardController.currentStoryboard.title,
            style: Theme.of(context).textTheme.headlineMedium,
            overflow: TextOverflow.fade,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            if (storyboardController.currentStoryboard.status ==
                    StoryStatus.UNPUBLISHED &&
                storyboardController.currentStoryboard.createdBy.userId ==
                    UserModel().user.userId)
              InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Iconsax.menu),
                  ),
                  onTap: () {})
          ],
        ),
        body: SizedBox(
            height: height,
            child: const Stack(
              children: [
                SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Stack(children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text("list stories")])
                    ])),
              ],
            )));
  }
}
