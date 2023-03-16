import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/api/machi/message_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/widgets/bot/share_message.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:uuid/uuid.dart';

// class BotChatScreen extends StatefulWidget {
//   const BotChatScreen({Key? key}) : super(key: key);
//
//   @override
//   _BotChatScreenState createState() => _BotChatScreenState();
// }
// class _BotChatScreenState extends State<BotChatScreen> {
/// _messages are state;
/// instead of continuously retrieving -
/// 1. Get last message on server
/// 2. Check local database an compare timestamp
/// 3. if not match, fetch all messages
/// 4. set state to messages
/// 5. chatController will save of all messages
class BotChatScreen extends StatelessWidget {
  final BotController botController = Get.find();
  final ChatController chatController = Get.find();
  late types.User _user;
  late AppLocalizations _i18n;

  List<types.Message> _messages = [];
  // late Stream<List<types.Message>> _streamMessages;
  final _messagesApi = MessageMachiApi();
  bool isLoading = false;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  BotChatScreen({Key? key}) : super(key: key);

  Future<void> _fetchLocalMessages() async {
    List<types.Message> localMessage = await _messagesApi.getLocalDbMessages();
    List<types.Message> lastRemoteMessage = await _messagesApi.getMessages(0, 1);

    if (localMessage.isNotEmpty) {
      int localTimestamp = localMessage[0].createdAt?.toInt() ?? 0;
      if (lastRemoteMessage[0].createdAt! <= localTimestamp ) {
        debugPrint("Using db -> local. Message length ${localMessage.length}");
        chatController.addMultipleMessages(localMessage);
        return;
      }
    }
    _fetchRemoteUserMessages();
  }

  Future<void> _fetchRemoteUserMessages() async {
    List<types.Message> messages = await _messagesApi.getMessages(0, 50);
    debugPrint("Using db -> remote. Message length ${messages.length}");
    chatController.addMultipleMessages(messages);
  }

  @override
  Widget build(BuildContext context) {
    /// Initializationd
    _i18n = AppLocalizations.of(context);
    double screenHeight = MediaQuery.of(context).size.height;
    chatController.onChatLoad();
    _user = chatController.chatUser;
    // fetch local messages
    // then match latest timestamp with last remote message
    _fetchLocalMessages();


    if (isLoading) {
      return const Frankloader();
    } else {
      return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              color: Theme
                  .of(context)
                  .primaryColor,
              onPressed: () {
                if (chatController.isTest == false) {
                  botController.fetchCurrentBot(DEFAULT_BOT_ID);
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
                // Navigator.of(context).pop();
              },
            ),
            // Show User profile info
            title: GestureDetector(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 0),
                title: Text(botController.bot.name,
                    style: const TextStyle(fontSize: 24)),
              ),
              onTap: () {
                /// Show bot info
                confirmDialog(context,
                    title:
                    "${_i18n.translate("about")} ${botController.bot.name}",
                    message:
                    "${botController.bot.name} is using ${botController.bot
                        .model}. \n${botController.bot.about} ",
                    positiveText: _i18n.translate("OK"),
                    positiveAction: () async {
                      // Close the confirm dialog
                      Navigator.of(context).pop();
                    });
              },
            ),
          ),
          body: StreamBuilder<List<types.Message>>(
              stream: chatController.streamList,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Frankloader();
                }
                return Chat(
                    showUserNames: true,
                    showUserAvatars: true,
                    // isAttachmentUploading: _isAttachmentUploading,
                    messages: snapshot.data!,
                    onSendPressed: _handleSendPressed,
                    user:_user);
              }
          )
      );
    }
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: chatController.chatUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        // mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      // _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: chatController.chatUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      // _addMessage(message);
    }
  }


  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: chatController.chatUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    // _addMessage(textMessage);
    _callAPI(message);


    // await _messagesApi.saveChatMessage(message);

  }


  /// call bot model api
  Future<void> _callAPI(dynamic message) async {

    await _messagesApi.saveChatMessage(message);
    // _streamMessages
  }





}
