import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/list_comments.dart';
import 'package:machi_app/widgets/storyboard/story_stats_action.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StoryboardView extends StatefulWidget {
  final Storyboard storyboard;
  const StoryboardView({Key? key, required this.storyboard}) : super(key: key);

  @override
  _StoryboardViewState createState() => _StoryboardViewState();
}

class _StoryboardViewState extends State<StoryboardView> {
  late AppLocalizations _i18n;
  final _commentApi = CommentApi();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storyboard"),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Get.back();
            },
          ),
        ),
        body: SizedBox(
            height: height,
            child: Stack(
              children: [
                SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: TimelineHeader(
                                  showAvatar: true,
                                  user: widget.storyboard.createdBy)),
                          // StoryViewDetails(story: widget.story),
                          StoryStatsAction(story: widget.storyboard),
                          ListComments(
                              storyboardId: widget.storyboard.storyboardId),
                        ])),
                Positioned(
                  bottom: 0,
                  child: _commentStory(),
                ),
              ],
            )));
  }

  Widget _commentStory() {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(10),
      width: width,
      child: TextFormField(
        maxLength: 200,
        controller: _commentController,
        decoration: InputDecoration(
            // labelText: _i18n.translate("bot_name"),
            hintText: _i18n.translate("story_comment"),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            suffixIcon: IconButton(
              icon: const Icon(Iconsax.send_2),
              onPressed: () {
                _postComment();
              },
            )),
        validator: (name) {
          // Basic validation
          if (name?.isEmpty ?? false) {
            return _i18n.translate("required_field");
          }
          if (name?.isNotEmpty == true && name!.length < 2) {
            return _i18n.translate("required_2_char");
          }
          return null;
        },
      ),
    );
  }

  void _postComment() async {
    String comment = _commentController.text;
    try {
      await _commentApi.postComment(widget.storyboard.storyboardId, comment);
      Get.snackbar(
        _i18n.translate("posted"),
        _i18n.translate("story_comment_sucess"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
    } catch (err) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
