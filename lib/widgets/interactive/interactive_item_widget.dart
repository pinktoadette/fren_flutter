import 'package:get/get.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/interactive/interactive_board_page.dart';
import 'package:machi_app/widgets/story_cover.dart';

class InteractiveItem extends StatefulWidget {
  final InteractiveBoard item;
  const InteractiveItem({Key? key, required this.item}) : super(key: key);

  @override
  _InteractiveItemWidgetState createState() => _InteractiveItemWidgetState();
}

class _InteractiveItemWidgetState extends State<InteractiveItem> {
  final _interactiveApi = InteractiveBoardApi();
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    double padding = 15;

    return InkWell(
        onTap: () async {
          Get.lazyPut<CommentController>(() => CommentController(),
              tag: "comment");

          Get.to(() => InteractivePageView(interactive: widget.item));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          width: size.width - padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.item.photoUrl != "")
                    StoryCover(
                        width: size.width * 0.4 - padding * 4,
                        height: size.width * 0.4 - padding * 4,
                        photoUrl: widget.item.photoUrl ?? "",
                        title: widget.item.category!),
                  Container(
                      padding: EdgeInsets.only(
                          left: widget.item.photoUrl != "" ? 10 : 0),
                      width: size.width * 0.6 -
                          (widget.item.photoUrl != "" ? padding * 2 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.summary!,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(widget.item.category!,
                              style: const TextStyle(
                                  fontSize: 14, color: APP_MUTED_COLOR)),
                        ],
                      )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ));
  }
}
