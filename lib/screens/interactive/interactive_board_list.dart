import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/interactive/interactive_board_page.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';

class InteractiveBoardList extends StatefulWidget {
  const InteractiveBoardList({Key? key}) : super(key: key);

  @override
  _InteractiveBoardListState createState() => _InteractiveBoardListState();
}

class _InteractiveBoardListState extends State<InteractiveBoardList> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _interactiveApi = InteractiveBoardApi();
  late AppLocalizations _i18n;
  List<InteractiveBoard> interactive = [];
  final PagingController<int, InteractiveBoard> _pagingController =
      PagingController(firstPageKey: 0);
  static const int _pageSize = ALL_PAGE_SIZE;

  @override
  void initState() {
    super.initState();
    _getInteractiveBoards(0);
  }

  void _getInteractiveBoards(int pageKey) async {
    try {
      List<InteractiveBoard> newItems =
          await _interactiveApi.getAllInteractive(page: pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text(_i18n.translate("interactive")),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              await _interactiveApi.getAllInteractive(page: 0);
            },
            child: PagedListView<int, InteractiveBoard>.separated(
              pagingController: _pagingController,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              builderDelegate: PagedChildBuilderDelegate<InteractiveBoard>(
                  firstPageProgressIndicatorBuilder: (_) => const Frankloader(),
                  newPageProgressIndicatorBuilder: (_) => const Frankloader(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                        onTap: () => Get.to(
                            () => InteractivePageView(interactive: item)),
                        child: Text(item.category));
                  }),
              separatorBuilder: (BuildContext context, int index) {
                if ((index + 1) % 3 == 0) {
                  return Padding(
                    padding:
                        const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                    child: Container(
                      height: AD_HEIGHT,
                      width: size.width,
                      color: Theme.of(context).colorScheme.background,
                      child: const InlineAdaptiveAds(),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )));
  }
}
