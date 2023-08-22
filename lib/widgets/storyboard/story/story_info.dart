import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';
import 'package:machi_app/widgets/story_cover.dart';

class StoryInfo extends StatefulWidget {
  const StoryInfo({Key? key}) : super(key: key);

  @override
  State<StoryInfo> createState() => _StoryInfoState();
}

class _StoryInfoState extends State<StoryInfo> {
  List<dynamic> contributors = [];
  final _storyboardApi = StoryboardApi();
  final _botApi = BotApi();
  final _cancelToken = CancelToken();
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

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  _fetchContributors() async {
    if (!mounted) {
      return;
    }
    Storyboard storyboard = storyboardController.currentStoryboard;

    List<dynamic> contribute = await _storyboardApi.getContributors(
        storyboardId: storyboard.storyboardId, cancelToken: _cancelToken);

    setState(() {
      contributors = contribute;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Obx(() => Container(
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
                photoUrl: storyboardController.currentStory.photoUrl ?? "",
                title: storyboardController.currentStory.title,
              )),
              const SizedBox(
                height: 20,
              ),
              Semantics(
                  label: storyboardController.currentStory.title,
                  child: Text(
                    storyboardController.currentStory.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  )),
              Row(children: [
                ...contributors.map((contribute) => TextButton(
                    onPressed: () async {
                      if (contribute['characterId'].contains(BOT_PREFIX)) {
                        Bot bot = await _botApi.getBot(
                            botId: contribute['characterId']);
                        _showBotInfo(bot);
                      }
                    },
                    child: Text(
                        contribute['characterId'].contains(BOT_PREFIX)
                            ? "🤖${contribute['character']} "
                            : contribute['character'],
                        style: Theme.of(context).textTheme.labelSmall)))
              ]),
              const SizedBox(
                height: 20,
              ),
              Semantics(
                label: storyboardController.currentStory.summary ?? "",
                child: Text(storyboardController.currentStory.summary ?? ""),
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
            ],
          ),
        ));
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
            showChatbuttom: true,
          ),
        );
      },
    );
  }
}
