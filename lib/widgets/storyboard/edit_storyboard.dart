import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/preview_storyboard.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class EditStory extends StatefulWidget {
  final Storyboard story;
  final int storyIdx;
  const EditStory({Key? key, required this.story, required this.storyIdx})
      : super(key: key);

  @override
  _EditStoryState createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();

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
        body: Obx(() => Padding(
            padding: const EdgeInsets.all(10.0),
            child: storyboardController.stories[widget.storyIdx].scene == null
                ? const Text("No stories")
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ReorderableListView(
                          children: <Widget>[
                            for (int index = 0;
                                index <
                                    storyboardController
                                        .stories[widget.storyIdx].scene!.length;
                                index += 1)
                              Container(
                                  key: ValueKey(storyboardController
                                      .stories[widget.storyIdx]
                                      .scene![index]
                                      .seq),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Colors.grey),
                                    ),
                                  ),
                                  child: ListTile(
                                    isThreeLine: true,
                                    title: Text(storyboardController
                                        .stories[widget.storyIdx]
                                        .scene![index]
                                        .messages
                                        .author
                                        .firstName!),
                                    subtitle: _showMessage(
                                        context,
                                        storyboardController
                                            .stories[widget.storyIdx]
                                            .scene![index]
                                            .messages),
                                    trailing: const Icon(Iconsax.menu_1),
                                  ))
                          ],
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              final Scene item = storyboardController
                                  .stories[widget.storyIdx].scene!
                                  .removeAt(oldIndex);
                              storyboardController
                                  .stories[widget.storyIdx].scene!
                                  .insert(newIndex, item);
                            });
                          },
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(PreviewStory(
                                  story: storyboardController
                                      .stories[widget.storyIdx]));
                            },
                            child: const Text("Preview"),
                          ))
                    ],
                  ))));
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message;
    Widget icons = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    _deleteMessage(message);
                  },
                  icon: const Icon(
                    Iconsax.trash,
                    size: 20,
                  ))
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

  void _deleteMessage(dynamic message) async {
    confirmDialog(context,
        positiveText: _i18n.translate("OK"),
        message: _i18n.translate("story_sure_delete"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveAction: () async {
          try {
            await _storyApi.removeStory(
                widget.storyIdx, message.id, widget.story.storyboardId);
            Navigator.of(context).pop();
          } catch (_) {
            Get.snackbar(
              'Error',
              _i18n.translate("an_error_has_occurred"),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: APP_ERROR,
            );
          }
        });
  }
}
