import 'package:flutter/material.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class QuickChat extends StatefulWidget {
  const QuickChat({Key? key}) : super(key: key);

  @override
  _QuickChatState createState() => _QuickChatState();
}

class _QuickChatState extends State<QuickChat> {
  ChatController chatController = Get.find();
  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    fieldText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final _i18n = AppLocalizations.of(context);
    types.User user = chatController.chatUser;

    _handleSendPressed() {
      chatController.onChatLoad();
      types.TextMessage message = chatController.createMessage(fieldText.text, user);
      chatController.addMessage(message);

      fieldText.clear();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const BotChatScreen()
      ));
    }

    return  TextField(
      autofocus: false,
      style: const TextStyle(color: Colors.white),
      controller: fieldText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        fillColor: Colors.black,
        filled: true,
        hintText: _i18n.translate("ask_something"),
        hintStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        suffixIcon:  GestureDetector(
          onTap: () {_handleSendPressed();},
          child: const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Icon(Iconsax.send_2, color: Colors.white),
          ),
        ),
      ),
    );
  }

}