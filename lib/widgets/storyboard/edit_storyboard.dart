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
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;

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
                ListView.separated(
                    separatorBuilder: (context, index) {
                      if ((index + 1) % 5 == 0) {
                        return Container(
                          height: itemHeight,
                          color: Theme.of(context).colorScheme.background,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Container(
                              height: 150,
                              width: width,
                              color: Colors.yellow,
                              child: const Text('ad placeholder'),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                    itemCount: widget.story.messages.length,
                    itemBuilder: (BuildContext ctx, index) {
                      final message = widget.story.messages[index];
                      return ListTile(
                        leading: Text("${index + 1}"),
                        title: Text(message.author.firstName!),
                        subtitle: _showMessage(message),
                        trailing: const Icon(Iconsax.menu_1),
                      );
                    }),
                Positioned(
                    bottom: 0,
                    right: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Preview"),
                    ))
              ],
            )));
  }

  Widget _showMessage(dynamic message) {
    final firstMessage = message;

    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Flexible(
            child: Text(
          firstMessage.text,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ));
      case (types.MessageType.image):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 110,
              child: Image.network(
                firstMessage.uri,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            )
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
