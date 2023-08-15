import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/storyboard/add_message_preview.dart';
import 'package:machi_app/widgets/storyboard/my_items/list_my_board.dart';

// ignore: must_be_immutable
class AddChatMessageToBoard extends StatefulWidget {
  types.Message message;
  AddChatMessageToBoard({Key? key, required this.message}) : super(key: key);

  @override
  State<AddChatMessageToBoard> createState() => _AddChatMessageToBoardState();
}

class _AddChatMessageToBoardState extends State<AddChatMessageToBoard> {
  late AppLocalizations _i18n;
  String errorMessage = '';
  bool isLoading = false;
  final _storyboardApi = StoryboardApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 15, top: 15),
          width: size.width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _i18n.translate("creative_mix"),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _i18n.translate("creative_mix_save_text"),
              style: Theme.of(context).textTheme.labelSmall,
            )
          ]),
        ),
        PreviewMessageToAdd(
          message: widget.message,
        ),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              icon: isLoading == true
                  ? loadingButton(size: 16)
                  : const Icon(Iconsax.add),
              label: Text(
                _i18n.translate("add_to_new_creativemix"),
              ),
              onPressed: () async {
                _addMessage();
              },
            )),
        const SizedBox(
          height: 5,
        ),
        const Divider(),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: size.height - 345,
                child: ListPrivateBoard(message: widget.message),
              )
            ],
          ),
        )
      ],
    );
  }

  void _addMessage() async {
    setState(() {
      isLoading = true;
    });
    try {
      dynamic message = widget.message;
      if (widget.message.type == types.MessageType.text) {
        await _storyboardApi.createStoryboard(
            character: widget.message.author.firstName,
            text: message.text,
            characterId: widget.message.author.id);
      }
      if (widget.message.type == types.MessageType.image) {
        await _storyboardApi.createStoryboard(
            image: message.uri,
            text:
                message.metadata != null ? _getImageText(message.metadata) : "",
            character: widget.message.author.firstName,
            characterId: widget.message.author.id);
      }
      Get.back(result: true);
      Get.snackbar(_i18n.translate("success"),
          _i18n.translate("creative_mix_edit_added_messages"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot add message in add message board bottom sheet',
          fatal: false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getImageText(Map<String, dynamic> metadata) {
    if (metadata.containsKey("caption")) {
      return metadata["caption"];
    }
    if (metadata.containsKey("text")) {
      return metadata["text"];
    }
    return "";
  }
}
