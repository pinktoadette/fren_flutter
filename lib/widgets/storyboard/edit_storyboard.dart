import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class EditStory extends StatefulWidget {
  final Storyboard story;
  const EditStory({Key? key, required this.story}) : super(key: key);

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(
              _i18n.translate("storyboard_edit"),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            leading: BackButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                Navigator.of(context).pop();
              },
            )),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 4 / 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: widget.story.messages.length,
              itemBuilder: (BuildContext ctx, index) {
                types.Message message = widget.story.messages[index];
                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.topLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(message.createdAt.toString(),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black)),
                        ]),
                  ),
                );
              }),
        ));
  }
}
