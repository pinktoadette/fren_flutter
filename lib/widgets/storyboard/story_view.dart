import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/list_comments.dart';
import 'package:fren_app/widgets/storyboard/story_stats_action.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StoryView extends StatefulWidget {
  final Storyboard story;
  const StoryView({Key? key, required this.story}) : super(key: key);

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;

    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: ListView(
          children: [
            Text(
              widget.story.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.left,
            ),
            ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.story.scene!.length,
                itemBuilder: (BuildContext ctx, index) {
                  final message = widget.story.scene![index].messages;

                  return ListTile(
                    isThreeLine: true,
                    subtitle: _showMessage(context, message),
                  );
                }),
            StoryStatsAction(story: widget.story),
            const SizedBox(
              height: 100,
            ),
            SizedBox(
              child: ListComments(storyboardId: widget.story.storyboardId),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ));
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
                child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                firstMessage.uri,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )),
          ],
        );
      default:
        return const Icon(Iconsax.activity);
    }
  }
}
