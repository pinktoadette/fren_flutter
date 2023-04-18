import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/preview_storyboard.dart';
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
          ),
          actions: [
            // Save changes button
            TextButton(
              child: Text(_i18n.translate("SAVE")),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ReorderableListView(
                    children: <Widget>[
                      for (int index = 0;
                          index < widget.story.scene.length;
                          index += 1)
                        Container(
                            key: ValueKey(widget.story.scene[index].seq),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            child: ListTile(
                              isThreeLine: true,
                              title: Text(widget.story.scene[index].messages
                                  .author.firstName!),
                              subtitle: _showMessage(
                                  context, widget.story.scene[index].messages),
                              trailing: const Icon(Iconsax.menu_1),
                            ))
                    ],
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final Scene item =
                            widget.story.scene.removeAt(oldIndex);
                        widget.story.scene.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(PreviewStory(story: widget.story));
                      },
                      child: const Text("Preview"),
                    ))
              ],
            )));
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message;
    Widget icons = const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Iconsax.trash,
                size: 20,
              )
            ],
          ),
        )
      ],
    );
    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Column(children: [Text(firstMessage.text), icons]);
      case (types.MessageType.image):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: Image.network(
                firstMessage.uri,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            icons
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
