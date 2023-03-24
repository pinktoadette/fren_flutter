import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/api/machi/message_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/controller/message_controller.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/socks/socket_manager.dart';
import 'package:fren_app/widgets/bot/tiny_bot.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

class BotChatScreen extends StatefulWidget {
  const BotChatScreen({Key? key}) : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  // BotChatScreen({Key? key}) : super(key: key);
  /// _messages are state;
  /// instead of continuously retrieving -
  /// 1. Get last message on server
  /// 2. Check local database an compare timestamp
  /// 3. if not match, fetch all messages
  /// 4. set state to messages
  /// 5. chatController will save of all messages
  final BotController botController = Get.find();
  final ChatController chatController = Get.find();
  final MessageController messageController = Get.find();

  late types.User _user;
  late AppLocalizations _i18n;
  final _messagesApi = MessageMachiApi();

  late Chatroom _room;

  bool _isAttachmentUploading = false;
  bool isLoading = false;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  Future<void> _listenSocket() async {
    print("_listen to socket");

    final _authApi = AuthApi();
    StreamSocket streamSocket = StreamSocket();

    Map<String, dynamic> headers = await _authApi.getHeaders();
    Socket socket = io(
        "${SOCKET_WS}ws/test",
        OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders(headers)
            .build());

    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });

    //When an event recieved from server, data is added to the stream
    socket.on('event',
        (data) => {print("printing socket data received: ${data.toString()}")});
    socket.onDisconnect((_) => print('disconnect'));
  }

  @override
  void initState() {
    _user = chatController.chatUser;
    _room = chatController.currentRoom;

    print("chat init state");

    super.initState();
    _listenSocket();
  }

  @override
  Widget build(BuildContext context) {
    /// Initializationd
    _i18n = AppLocalizations.of(context);

    if (isLoading) {
      return const Frankloader();
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              if (chatController.isTest == false) {
                botController.fetchCurrentBot(DEFAULT_BOT_ID);
              }

              Navigator.of(context).pop();

              Get.delete<MessageController>().then((_) {
                Get.put(MessageController());
              }).then((_) => messageController.offset = 10);
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
                      "${botController.bot.name}. \n${botController.bot.about} \nThis chatroom I have a ${_room.personality} manner.",
                  positiveText: _i18n.translate("OK"),
                  positiveAction: () async {
                // Close the confirm dialog
                Navigator.of(context).pop();
              });
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const TinyBotIcon(image: 'assets/images/faces/1.png'),
              onPressed: () {
                infoDialog(context,
                    title: _i18n.translate("bot_naps"),
                    message: _i18n.translate("bot_nap_message"),
                    positiveText: _i18n.translate("OK"),
                    positiveAction: () async {
                  // Close the confirm dialog
                  Navigator.of(context).pop();
                });
              },
            ),
            PopupMenuButton<String>(
              initialValue: "",
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                /// invite_user
                PopupMenuItem(
                    value: "invite_user",
                    child: Row(
                      children: <Widget>[
                        const TinyBotIcon(image: 'assets/images/pink_bot.png'),
                        const SizedBox(width: 5),
                        Text(_i18n.translate("invite_user")),
                      ],
                    )),

                /// change_bot_personality
                PopupMenuItem(
                    value: "change_bot_personality",
                    child: Row(
                      children: <Widget>[
                        const TinyBotIcon(image: 'assets/images/frank1.png'),
                        const SizedBox(width: 5),
                        Text(_i18n.translate("change_bot_personality"))
                      ],
                    )),
              ],
              onSelected: (val) {
                /// Control selected value
                switch (val) {
                  case "delete_chat":

                    /// Delete chat
                    confirmDialog(context,
                        title: _i18n.translate("delete_conversation"),
                        message:
                            _i18n.translate("conversation_will_be_deleted"),
                        negativeAction: () => Navigator.of(context).pop(),
                        positiveText: _i18n.translate("DELETE"),
                        positiveAction: () async {
                          // Close the confirm dialog
                          Navigator.of(context).pop();
                        });
                    break;

                  // Handle Block/Unblock profile
                  case "block":
                    // Check remote user blocked status
                    //   if (_isRemoteUserBlocked != null && _isRemoteUserBlocked!) {
                    //     // Unblock profile
                    //     _unblockProfile();
                    //   } else {
                    //     // Unblock profile
                    //     _blockProfile();
                    //   }
                    break;
                }
                debugPrint("Selected action: $val");
              },
            ),
          ],
        ),
        body: StreamBuilder<Chatroom>(
          initialData: _room,
          stream: chatController.streamRoom,
          builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream:
                Get.put(MessageController()).streamMessages, // get on socket
            builder: (context, snapshot) => Chat(
                theme: DefaultChatTheme(
                    primaryColor: Theme.of(context).colorScheme.secondary,
                    sendButtonIcon:
                        const Icon(Iconsax.send_2, color: Colors.white)),
                onEndReached: _loadMoreMessage, //get more messages on top
                showUserNames: true,
                showUserAvatars: true,
                isAttachmentUploading: _isAttachmentUploading,
                messages: snapshot.data!,
                onSendPressed: _handleSendPressed,
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                user: _user),
          ),
        ),
      );
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          // final index =
          // _messages.indexWhere((element) => element.id == message.id);
          // final updatedMessage =
          // (_messages[index] as types.FileMessage).copyWith(
          //   isLoading: true,
          // );
          //
          //
          // final client = http.Client();
          // final request = await client.get(Uri.parse(message.uri));
          // final bytes = request.bodyBytes;
          // final documentsDir = (await getApplicationDocumentsDirectory()).path;
          // localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            // await file.writeAsBytes(bytes);
          }
        } finally {
          // final index =
          // _messages.indexWhere((element) => element.id == message.id);
          // final updatedMessage =
          // (_messages[index] as types.FileMessage).copyWith(
          //   isLoading: null,
          // );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
//     final index = _messages.indexWhere((element) => element.id == message.id);
//     final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
//       previewData: previewData,
//     );
// ]
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

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// call bot model api
  Future<void> _callAPI(dynamic message) async {
    setState(() {
      _isAttachmentUploading = true;
    });
    try {
      Map<String, dynamic> messageMap =
          await _messagesApi.formatChatMessage(message);
      await _messagesApi.saveUserResponse(messageMap);
      await _messagesApi.getBotResponse(messageMap);
    } catch (err) {
      showScaffoldMessage(
          message: _i18n.translate("an_error_has_occurred"),
          bgcolor: Colors.red);
    }

    setState(() {
      _isAttachmentUploading = false;
    });
  }

  Future<void> _loadMoreMessage() async {
    try {
      await _messagesApi.getMessages();
    } catch (err) {
      log(err.toString());
      showScaffoldMessage(
          message: _i18n.translate("an_error_has_occurred"),
          bgcolor: Colors.red);
    }
  }
}
