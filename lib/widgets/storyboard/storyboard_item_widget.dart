import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/my_edit/create_outline_page.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
class StoryboardItemWidget extends StatefulWidget {
  final Storyboard item;
  final types.Message? message;
  final bool? hideCollection;
  final bool? showHeader;
  const StoryboardItemWidget(
      {Key? key,
      required this.item,
      this.message,
      this.hideCollection = false,
      this.showHeader = true})
      : super(key: key);

  @override
  State<StoryboardItemWidget> createState() => _StoryboardItemWidgettState();
}

class _StoryboardItemWidgettState extends State<StoryboardItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');
  UserController userController = Get.find(tag: 'user');

  late Storyboard storyboard;
  late AppLocalizations _i18n;
  late double width;
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    super.initState();
    setState(() {
      storyboard = widget.item;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    width = MediaQuery.of(context).size.width;
    double padding = 15;

    String timestampLabel = storyboard.status == StoryStatus.PUBLISHED
        ? "Published on "
        : "Last Updated ";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showHeader == true)
          Container(
            padding: EdgeInsets.only(top: padding, bottom: padding),
            width: width,
            child: TimelineHeader(
              radius: 24,
              user: storyboard.createdBy,
              showName: true,
              showMenu: false,
              underNameRow:
                  Text("$timestampLabel ${formatDate(storyboard.updatedAt)}",
                      style: const TextStyle(
                        fontSize: 12,
                      )),
            ),
          ),
        _displayType(storyboard, padding, width),
        if (widget.hideCollection == false)
          Row(children: _showCollectionFooter())
      ],
    );
  }

  Widget _displayType(Storyboard storyboard, double padding, double width) {
    final firstStory = storyboard.story!.first;

    if (firstStory.layout == Layout.COMIC) {
      return _buildComicLayout(firstStory, width);
    }

    return _buildDefaultLayout(storyboard, padding, width, firstStory);
  }

  Widget _buildComicLayout(Story story, double width) {
    const index = 0;
    final displayText = truncateScriptsTo250Chars(
      scripts: story.pages![0].scripts,
      length: 300,
    );
    final firstScriptWithImage = story.pages![0].scripts!.firstWhere(
      (script) => script.type == 'image',
      orElse: () => Script(image: null),
    );
    final imageUrl = story.pages![index].backgroundImageUrl;
    final defaultImage = Image.asset(
      "assets/images/blank.png",
      scale: 0.2,
      width: 100,
    ).image;

    return InkWell(
      onTap: _navigateNextPage,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        width: width,
        height: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(255, 0, 0, 0).withOpacity(
                story.pages![index].backgroundAlpha ?? 0.5,
              ),
              BlendMode.darken,
            ),
            image:
                imageUrl != null ? ImageCacheWrapper(imageUrl) : defaultImage,
            fit: BoxFit.cover,
          ),
        ),
        child: _buildComicChild(
            displayText, firstScriptWithImage, story.layout ?? Layout.COMIC),
      ),
    );
  }

  Widget _buildComicChild(
    String displayText,
    Script firstScriptWithImage,
    Layout layout,
  ) {
    if (displayText.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: textLinkPreview(
          useBorder: layout == Layout.COMIC,
          context: context, // Replace with your context source
          text: displayText,
          maxLines: 9,
          style: const TextStyle(color: Colors.black),
        ),
      );
    } else if (firstScriptWithImage.image != null) {
      return StoryCover(
        photoUrl: firstScriptWithImage.image!.uri,
        title: "",
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDefaultLayout(
    Storyboard storyboard,
    double padding,
    double width,
    Story firstStory,
  ) {
    final photoUrl = storyboard.photoUrl ?? "";
    final title = firstStory.title;
    String subtitle = truncateText(
      maxLength: 200,
      text: firstStory.summary ?? "",
    );

    return InkWell(
      onTap: _navigateNextPage,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: width - padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(left: photoUrl != "" ? 10 : 0),
                width: width - (photoUrl != "" ? padding * 2 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(storyboard.category,
                        style: const TextStyle(
                            fontSize: 14, color: APP_MUTED_COLOR)),
                  ],
                )),
            if (photoUrl != "")
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoryCover(
                      width: width * 0.4 - padding * 4,
                      height: width * 0.4 - padding * 4,
                      photoUrl: photoUrl,
                      title: title),
                  if (subtitle != "")
                    Container(
                        padding: EdgeInsets.only(left: photoUrl != "" ? 10 : 0),
                        width: width * 0.6 - (photoUrl != "" ? padding * 2 : 0),
                        child:
                            textLinkPreview(context: context, text: subtitle))
                ],
              ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _showCollectionFooter() {
    bool hasSeries = storyboard.story != null && storyboard.story!.length > 1;
    return [
      if (hasSeries && userController.user != null)
        ...storyboard.story!.take(4).map((s) {
          return InkWell(
            onTap: () {
              storyboardController.setCurrentBoard(storyboard);
              timelineController.setStoryTimelineControllerCurrent(s);
              storyboardController.onGoToPageView(s);
              Get.to(() => StoryPageView(story: s));
            },
            child: StoryCover(
                height: 80,
                width: 80,
                photoUrl: s.photoUrl ?? "",
                title: s.title),
          );
        })
      else
        _likeItemWidget(storyboard.story![0], false),
      const SizedBox(
        height: 20,
      )
    ];
  }

  Future<void> _navigateNextPage() async {
    NavigationHelper.handleGoToPageOrLogin(
      context: context,
      userController: userController,
      navigateAction: () {
        _onStoryClick();
      },
    );
  }

  Future<void> _onStoryClick() async {
    /// if there is only one story, then go to the story bits
    /// if theres more than one, then show entire collection
    storyboardController.setCurrentBoard(storyboard);
    if (widget.message != null) {
      Get.to(() => StoriesView(message: widget.message!));
    } else {
      Get.lazyPut<CommentController>(() => CommentController(), tag: "comment");

      if ((storyboard.story!.isNotEmpty) & (storyboard.story!.length == 1)) {
        timelineController
            .setStoryTimelineControllerCurrent(storyboard.story![0]);

        if (storyboard.story![0].status == StoryStatus.UNPUBLISHED) {
          Get.to(() => const CreateOutlinePage());
        } else {
          Get.to(() => StoryPageView(story: storyboard.story![0]));
        }
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StoriesView(),
          ),
        ).then((_) {
          setState(() {
            storyboard = storyboardController.currentStoryboard;
          });
        });
      }
    }
  }

  /// likes should be on timeline. You dont like your own stuff
  Future<void> _onLikePressed(Story item, bool value) async {
    storyboardController.setCurrentBoard(storyboard);

    String response = await _timelineApi.likeStoryMachi(
        "story", item.storyId, value == true ? 1 : 0);
    if (response == "OK") {
      Story update = item.copyWith(
          mylikes: value == true ? 1 : 0,
          likes: value == true ? (item.likes! + 1) : (item.likes! - 1));
      timelineController.updateStoryboard(
          storyboard: storyboard, updateStory: update);
    }
  }

  Widget _likeItemWidget(Story item, bool removeLeftPadding) {
    return InkWell(
      onTap: () async {
        _navigateNextPage();
      },
      child: Padding(
          padding: EdgeInsets.only(
              left: removeLeftPadding == true ? 0 : 15, bottom: 0, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 50,
                  child: LikeItemWidget(
                      onLike: (val) {
                        _onLikePressed(item, val);
                      },
                      likes: item.likes ?? 0,
                      mylikes: item.mylikes ?? 0)),
              Container(
                height: 35,
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: const Text("•"),
              ),
              SizedBox(
                  height: 30,
                  child: Text(
                      "${_i18n.translate("replies")}  ${item.commentCount ?? 0} ",
                      style: const TextStyle(fontSize: 14))),
            ],
          )),
    );
  }
}
