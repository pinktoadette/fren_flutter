import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:get/get.dart';

class ListMyStoryboard extends StatefulWidget {
  final types.Message? message;
  const ListMyStoryboard({Key? key, this.message}) : super(key: key);

  @override
  _MyStoryboardState createState() => _MyStoryboardState();
}

class _MyStoryboardState extends State<ListMyStoryboard> {
  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyboardApi = StoryboardApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    storyboardController.getUnpublised();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
        onRefresh: () async {
          // Refresh Functionality
          await _storyboardApi.getMyStoryboards(
              statusFilter: StoryStatus.UNPUBLISHED.name);
        },
        child: storyboardController.storyboards.isEmpty
            ? Align(
                alignment: Alignment.center,
                child: Text(
                  _i18n.translate("story_nothing"),
                  textAlign: TextAlign.center,
                ),
              )
            : Obx(
                () => ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      if ((index + 1) % 2 == 0) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                              top: 10, bottom: 10),
                          child: Container(
                            height: AD_HEIGHT,
                            width: width,
                            color: Theme.of(context).colorScheme.background,
                            child: const InlineAdaptiveAds(),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: storyboardController.unpublished.length,
                    itemBuilder: (BuildContext ctx, index) {
                      Storyboard story =
                          storyboardController.unpublished[index];
                      if (story.title == '') {
                        return NoData(
                            text: _i18n.translate("storycast_board_nothing"));
                      }
                      return StoryboardItemWidget(
                          message: widget.message, item: story);
                    }),
              ));
  }
}
