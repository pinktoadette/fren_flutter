import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/chat/title_cat_storyboard.dart';
import 'package:machi_app/widgets/storyboard/my_items/list_my_board.dart';

// ignore: must_be_immutable
class AddChatMessageToBoard extends StatefulWidget {
  types.Message message;
  AddChatMessageToBoard({Key? key, required this.message}) : super(key: key);

  @override
  _AddChatMessageToBoardState createState() => _AddChatMessageToBoardState();
}

class _AddChatMessageToBoardState extends State<AddChatMessageToBoard> {
  late AppLocalizations _i18n;
  String errorMessage = '';
  final _storyboardApi = StoryboardApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: Text(
            _i18n.translate("storycast_board"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              _i18n.translate("story_added_info"),
              style: Theme.of(context).textTheme.labelSmall,
            )),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              child: Text(_i18n.translate("add_to_new_storyboard")),
              onPressed: () async {
                _addMessage();
              },
            )),

        // StoryboardTitleCategory(
        //   onUpdate: (e) {
        //     _updateTitleCategory(e);
        //   },
        // ),
        const SizedBox(
          height: 5,
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(_i18n.translate("add_to_exist_storyboard"))),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height - 345,
                child: ListMyStoryboard(message: widget.message),
              )
            ],
          ),
        )
      ],
    );
  }

  void _addMessage() async {
    try {
      dynamic message = widget.message;
      if (widget.message.type == types.MessageType.text) {
        await _storyboardApi.createStoryboard(text: message.text);
      }
      if (widget.message.type == types.MessageType.image) {
        await _storyboardApi.createStoryboard(image: message.uri);
      }
    } catch (error) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("error_launch_url"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
