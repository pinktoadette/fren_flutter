import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';

class ListPromptBots extends StatefulWidget {
  const ListPromptBots({Key? key}) : super(key: key);

  @override
  State<ListPromptBots> createState() => _ListPromptBotState();
}

class _ListPromptBotState extends State<ListPromptBots> {
  final _botApi = BotApi();
  final PagingController<int, Bot> _pagingController =
      PagingController(firstPageKey: 0);
  final TextEditingController _searchController = TextEditingController();
  final _cancelToken = CancelToken();
  static const int _pageSize = ALL_PAGE_SIZE;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchAllBots(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    _cancelToken.cancel();
    super.dispose();
  }

  Future<void> _fetchAllBots(int pageKey) async {
    try {
      List<Bot> newItems = await _botApi.getAllBots(
          page: pageKey,
          modelType: BotModelType.prompt,
          search: _searchController.text,
          cancelToken: _cancelToken);
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
    final i18n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    return Stack(alignment: Alignment.topCenter, children: [
      SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          PagedListView<int, dynamic>.separated(
            pagingController: _pagingController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
                noItemsFoundIndicatorBuilder: (_) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(i18n.translate("bots_not_found"))],
              );
            }, itemBuilder: (context, item, index) {
              return InkWell(
                  onTap: () {
                    Future(() {
                      SetCurrentRoom()
                          .setNewBotRoom(bot: item, createNew: true);
                    });
                    Navigator.pop(context);
                  },
                  child: BotProfileCard(bot: item));
            }),
            separatorBuilder: (BuildContext context, int index) {
              if ((index + 1) % 3 == 0) {
                return Padding(
                  padding:
                      const EdgeInsetsDirectional.only(top: 10, bottom: 10),
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
          ),
        ],
      )),
      Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(20),
        width: width,
        child: TextField(
          controller: _searchController,
          onChanged: (pattern) async {
            if (pattern.length >= 3) {
              await Future.delayed(const Duration(seconds: 2));
              _fetchAllBots(0);
              _pagingController.refresh();
            }
          },
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          decoration: InputDecoration(
              filled: true,
              prefixIcon: const Icon(
                Icons.search,
              ),
              hintText: i18n.translate("search")),
        ),
      ),
    ]);
  }
}
