import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';

import 'row_bot_info.dart';

class ListPromptBots extends StatefulWidget {
  const ListPromptBots({Key? key}) : super(key: key);

  @override
  _ListPromptBotState createState() => _ListPromptBotState();
}

class _ListPromptBotState extends State<ListPromptBots> {
  final _botApi = BotApi();
  final PagingController<int, Bot> _pagingController =
      PagingController(firstPageKey: 0);

  static const int _pageSize = ALL_PAGE_SIZE;

  Future<void> _fetchAllBots(int pageKey) async {
    try {
      List<Bot> newItems =
          await _botApi.getAllBots(pageKey, BotModelType.prompt);
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
  void initState() {
    _fetchAllBots(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;

    return PagedListView<int, dynamic>.separated(
      pagingController: _pagingController,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      builderDelegate:
          PagedChildBuilderDelegate<dynamic>(noItemsFoundIndicatorBuilder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(_i18n.translate("bots_not_found"))],
        );
      }, itemBuilder: (context, item, index) {
        return RowMachiInfo(bot: item);
      }),
      separatorBuilder: (BuildContext context, int index) {
        if ((index + 1) % 3 == 0) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
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
    );

    // return Container(
    //     margin: const EdgeInsets.symmetric(vertical: 5.0),
    //     child: ListView.separated(
    //         physics: const ClampingScrollPhysics(),
    //         shrinkWrap: true,
    //         scrollDirection: Axis.vertical,
    //         separatorBuilder: (context, index) {
    //           if ((index + 1) % 5 == 0) {
    //             return Container(
    //               height: itemHeight,
    //               color: Theme.of(context).colorScheme.background,
    //               child: Padding(
    //                 padding: const EdgeInsets.only(top: 10, bottom: 10),
    //                 child: Container(
    //                   height: AD_HEIGHT,
    //                   width: width,
    //                   color: Theme.of(context).colorScheme.background,
    //                   child: const InlineAdaptiveAds(),
    //                 ),
    //               ),
    //             );
    //           } else {
    //             return const Divider();
    //           }
    //         },
    //         itemCount: _listBot.length,
    //         itemBuilder: (context, index) =>
    //             RowMachiInfo(bot: _listBot[index])));
  }
}
