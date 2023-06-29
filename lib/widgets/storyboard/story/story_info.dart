import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryInfo extends StatefulWidget {
  const StoryInfo({Key? key}) : super(key: key);

  @override
  _StoryInfoState createState() => _StoryInfoState();
}

class _StoryInfoState extends State<StoryInfo> {
  List<dynamic> contributors = [];
  late AppLocalizations _i18n;
  final _storyboardApi = StoryboardApi();
  final _botApi = BotApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    setState(() {
      storyboard = storyboard;
    });
    super.initState();
    _fetchContributors();
  }

  _fetchContributors() async {
    Storyboard storyboard = storyboardController.currentStoryboard;

    List<dynamic> contribute = await _storyboardApi.getContributors(
        storyboardId: storyboard.storyboardId);
    setState(() {
      contributors = contribute;
    });
  }

  @override
  Widget build(BuildContext context) {
    Story story = storyboardController.currentStory;
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Center(
              child: StoryCover(
            width: size.width * 0.75,
            height: size.width * 0.75,
            photoUrl: story.photoUrl ?? "",
            title: story.title,
          )),
          const SizedBox(
            height: 20,
          ),
          Semantics(
              label: story.title,
              child: Text(
                story.title,
                style: Theme.of(context).textTheme.titleLarge,
              )),
          Row(children: [
            Semantics(
                label: _i18n.translate("story_contributors"),
                child: Text(
                  "${_i18n.translate("story_contributors")}: ",
                  style: Theme.of(context).textTheme.labelSmall,
                )),
            ...contributors.map((contribute) => TextButton(
                onPressed: () async {
                  if (contribute['characterId'].contains(BOT_PREFIX)) {
                    Bot bot =
                        await _botApi.getBot(botId: contribute['characterId']);
                    _showBotInfo(bot);
                  }
                },
                child: Text("${contribute['character']} ",
                    style: Theme.of(context).textTheme.labelSmall)))
          ]),
          const SizedBox(
            height: 20,
          ),
          Semantics(
            label: story.summary ?? "",
            child: Text(story.summary ?? ""),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }

  void _showBotInfo(Bot bot) {
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 400 / height,
            child: BotProfileCard(
              bot: bot,
            ));
      },
    );
  }
}
