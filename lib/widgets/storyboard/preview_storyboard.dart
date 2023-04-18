import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/publish_story.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PreviewStory extends StatefulWidget {
  final Storyboard story;
  const PreviewStory({Key? key, required this.story}) : super(key: key);

  @override
  _PreviewStoryState createState() => _PreviewStoryState();
}

class _PreviewStoryState extends State<PreviewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storyboard_preview"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ListView.builder(
                        itemCount: widget.story.scene!.length,
                        itemBuilder: (BuildContext ctx, index) {
                          final message = widget.story.scene![index].messages;
                          return ListTile(
                            isThreeLine: true,
                            subtitle: _showMessage(context, message),
                          );
                        })),
                Positioned(
                    bottom: 0,
                    right: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(const PublishStory());
                      },
                      child: Text(
                        _i18n.translate("publish"),
                      ),
                    ))
              ],
            )));
  }

  Widget _showMessage(BuildContext context, dynamic message) {
    final firstMessage = message;

    switch (firstMessage.type) {
      case (types.MessageType.text):
        return Text(firstMessage.text);
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
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
