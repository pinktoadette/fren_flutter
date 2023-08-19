import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/comment/comment_widget.dart';
import 'package:machi_app/widgets/comment/post_comment_widget.dart';

class PageCommentSheet extends StatefulWidget {
  const PageCommentSheet({super.key});

  @override
  State<PageCommentSheet> createState() => _PageCommentSheetState();
}

class _PageCommentSheetState extends State<PageCommentSheet> {
  late AppLocalizations _i18n;
  final controller = PageController(viewportFraction: 1, keepPage: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      expand: true,
      builder: (BuildContext context, ScrollController scrollController) {
        if (controller.hasClients) {}
        return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  child: Container(
                      color: const Color.fromARGB(255, 20, 20, 20),
                      child: Stack(children: [
                        CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                  child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.keyboard_double_arrow_up,
                                      size: 14,
                                      color: APP_INVERSE_PRIMARY_COLOR,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(_i18n.translate("comments"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color:
                                                    APP_INVERSE_PRIMARY_COLOR))
                                  ],
                                ),
                              )),
                              const CommentWidget(),
                              const SliverToBoxAdapter(
                                  child: SizedBox(
                                height: 100,
                              ))
                            ]),
                        const Positioned(bottom: 0, child: PostCommentWidget())
                      ])));
            });
      },
    );
  }
}
