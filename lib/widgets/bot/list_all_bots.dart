import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';
import 'package:machi_app/widgets/bot/search_bot.dart';

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
  late AppLocalizations _i18n;
  String? _searchTerm;

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
      final newItems = await _botApi.getAllBots(
        page: pageKey,
        modelType: BotModelType.prompt,
        search: _searchTerm,
        cancelToken: _cancelToken,
      );

      if (mounted && newItems.isNotEmpty) {
        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'Listing machi failed: ${error.toString()}',
        fatal: true,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverToBoxAdapter(child: SearchMachiField(onInputChanged: (term) {
        _updateSearchTerm(term);
      })),
      PagedSliverList<int, dynamic>.separated(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
            noItemsFoundIndicatorBuilder: (_) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(_i18n.translate("bots_not_found"))],
          );
        }, itemBuilder: (context, item, index) {
          return InkWell(
              onTap: () {
                Future(() {
                  SetCurrentRoom().setNewBotRoom(bot: item, createNew: true);
                });
                Navigator.pop(context);
              },
              child: BotProfileCard(bot: item));
        }),
        separatorBuilder: (BuildContext context, int index) {
          if ((index + 1) % 3 == 0) {
            return const InlineAdaptiveAds();
          } else {
            return const SizedBox.shrink();
          }
        },
      )
    ]);
  }
}
