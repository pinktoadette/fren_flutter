import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:get/get.dart';

class ListPrivateBoard extends StatefulWidget {
  final types.Message? message;
  const ListPrivateBoard({Key? key, this.message}) : super(key: key);

  @override
  State<ListPrivateBoard> createState() => _ListPrivateBoardState();
}

class _ListPrivateBoardState extends State<ListPrivateBoard> {
  final _storyboardApi = StoryboardApi();
  final StoryboardController storyboardController = Get.find(tag: 'storyboard');

  late AppLocalizations _i18n;
  double itemHeight = 120;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  void _getMyBoards() async {
    await storyboardController.getBoards(filter: StoryStatus.UNPUBLISHED);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = MediaQuery.of(context).size.width;

      return RefreshIndicator(
        onRefresh: () async {
          _getMyBoards();
        },
        child: Obx(() => ListView.separated(
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
                return const Divider();
              }
            },
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: storyboardController.storyboards.length,
            itemBuilder: (BuildContext ctx, index) {
              Storyboard storyboard = storyboardController.storyboards[index];
              if (storyboard.story!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Dismissible(
                  key: Key(storyboard.storyboardId),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (DismissDirection direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            _i18n.translate("DELETE"),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          content: Text(_i18n
                              .translate("creative_mix_are_you_sure_delete")),
                          actions: <Widget>[
                            OutlinedButton(
                                onPressed: () => {
                                      Navigator.of(context).pop(false),
                                    },
                                child: Text(_i18n.translate("CANCEL"))),
                            const SizedBox(
                              width: 50,
                            ),
                            ElevatedButton(
                                onPressed: () => {
                                      _onDelete(storyboard),
                                    },
                                child: Text(_i18n.translate("DELETE"))),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                      color: APP_ERROR, child: const Icon(Iconsax.trash)),
                  child: StoryboardItemWidget(
                    message: widget.message,
                    item: storyboard,
                    hideCollection: true,
                    showHeader: false,
                  ));
            })),
      );
    });
  }

  void _onDelete(Storyboard storyboard) async {
    try {
      await _storyboardApi.deleteBoard(storyboard);
      Get.back(result: true);
      Get.snackbar(_i18n.translate("DELETE"),
          _i18n.translate("creative_mix_success_delete"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err) {
      Get.snackbar(
        _i18n.translate("DELETE"),
        _i18n.translate("creative_mix_board_error"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
