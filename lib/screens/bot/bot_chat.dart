import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/helpers/message_format.dart';
import 'package:fren_app/helpers/uploader.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/bot/bot_timer.dart';
import 'package:fren_app/widgets/chat/double_tap_message.dart';
import 'package:fren_app/widgets/chat/header_input.dart';
import 'package:fren_app/widgets/friend_list.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
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
import 'package:fren_app/widgets/bot/tiny_bot.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class BotChatScreen extends StatefulWidget {
  const BotChatScreen({Key? key}) : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  final BotController botController = Get.find(tag: 'bot');
  final ChatController chatController = Get.find(tag: 'chatroom');
  final MessageController messageController = Get.find(tag: 'message');

  late final List<types.Message> _messages = [];

  late types.User _user;
  late AppLocalizations _i18n;
  late WebSocketChannel _channel;
  late Chatroom _room;
  late int _roomIdx;
  bool isTrial = false;
  final _messagesApi = MessageMachiApi();
  final _chatroomApi = ChatroomMachiApi();
  bool _isAttachmentUploading = false;
  bool isLoading = false;
  bool isBotSleeping = false;
  bool? isBotTyping;
  types.PartialImage? attachmentPreview;
  File? file;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  Future<void> _listenSocket() async {
    final _authApi = AuthApi();
    Map<String, dynamic> headers = await _authApi.getHeaders();
    final Uri wsUrl = Uri.parse('${SOCKET_WS}messages/${_room.chatroomId}');
    _channel = WebSocketChannel.connect(wsUrl);
    _channel.sink.add(json.encode({"token": headers}));
    _channel.stream
        .listen(
      (_) {},
      onError: (error) => Get.snackbar(
          'Error', _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: APP_ERROR),
    )
        .onData((data) {
      _onSocketParse(data);
    });
  }

  void _onSocketParse(String message) {
    Map<String, dynamic> decodeData = json.decode(message);
    types.Message newMessage = messageFromJson(decodeData["message"]);
    setState(() {
      _messages.insert(0, newMessage);
    });
    chatController.updateMessagesPreview(_roomIdx, newMessage);
  }

  @override
  void initState() {
    // get the room
    final args = Get.arguments;
    _room = args["room"];
    _user = chatController.chatUser;
    _roomIdx = args["index"];

    if (args["isTrial"] == true) {
      isTrial = args["isTrial"];
    }

    // get the messages loaded from the room
    _messages.addAll(_room.messages);

    //initialize socket
    _listenSocket();
    super.initState();
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initializationd
    _i18n = AppLocalizations.of(context);

    if (isLoading) {
      return Frankloader();
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              // if there are no messages, remove from roomList
              if ((_messages.isEmpty) &
                  (chatController.currentRoom.users.length == 1)) {
                chatController.removeEmptyRoomfromList();
              }
              if (isTrial == true) {
                chatController.removeSepcificBotFromRoom(_room);
              }
              botController.fetchCurrentBot(DEFAULT_BOT_ID);
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
              _showBotInfo();
            },
          ),
          actions: <Widget>[
            if (_room.users.length > 1)
              InkWell(
                child: const BotTimer(),
                onTap: () {
                  infoDialog(context,
                      icon: const TinyBotIcon(
                          image: 'assets/images/faces/napping.png'),
                      title: _i18n.translate("bot_naps"),
                      message: _i18n.translate("bot_nap_message"),
                      positiveText: _i18n.translate("OK"),
                      positiveAction: () async {
                    // Close the confirm dialog
                    Navigator.of(context).pop();
                  });
                },
              ),
            if (isTrial == false)
              PopupMenuButton<String>(
                initialValue: "",
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  /// invite_user
                  PopupMenuItem(
                      value: "add_to_chat",
                      child: Row(
                        children: <Widget>[
                          const Icon(Iconsax.add),
                          const SizedBox(width: 5),
                          Text(_i18n.translate("add_to_chat")),
                        ],
                      )),
                  if (_room.users.length > 1)
                    PopupMenuItem(
                        value: "leave_chat",
                        child: Row(
                          children: <Widget>[
                            const Icon(Iconsax.logout),
                            const SizedBox(width: 5),
                            Text(_i18n.translate("leave_chatroom")),
                          ],
                        )),
                ],
                onSelected: (val) {
                  /// Control selected value
                  switch (val) {
                    case "add_to_chat":
                      _showFriends();
                      break;
                    case "leave_chat":
                      _leaveChat(context);
                      break;
                  }
                },
              ),
          ],
        ),
        body: Chat(
            listBottomWidget: CustomHeaderInputWidget(
                notifyParent: (e) {
                  updateFromWidgets(e);
                },
                isBotTyping: isBotTyping,
                attachmentPreview: attachmentPreview),
            theme: DefaultChatTheme(
                inputTextStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                primaryColor: Theme.of(context).colorScheme.secondary,
                sendButtonIcon: const Icon(Iconsax.send_2, color: Colors.white),
                backgroundColor: Theme.of(context).colorScheme.background),
            onEndReached: _loadMoreMessage, //get more messages on top
            showUserNames: true,
            showUserAvatars: true,
            isAttachmentUploading: _isAttachmentUploading,
            messages: _messages,
            onMessageDoubleTap: _handleMessageDoubleTap,
            onSendPressed: _handleSendPressed,
            onAvatarTap: (messageUser) async {
              if (!messageUser.id.contains("Machi_")) {
                final user = await UserModel().getUserObject(messageUser.id);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user)));
              }
            },
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            user: _user),
      );
    }
  }

  void _handleMessageDoubleTap(BuildContext _, types.Message message) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => FractionallySizedBox(
          heightFactor: 0.9,
          child: DraggableScrollableSheet(
            snap: true,
            initialChildSize: 1,
            minChildSize: 0.75,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: DoubleTapChatMessage(
                message: message,
              ),
            ),
          )),
    );
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message, types.PreviewData previewData) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleImageSelection(File image) async {
    var bytes = image.readAsBytesSync();
    var result = await decodeImageFromList(bytes);
    types.PartialImage message = types.PartialImage(
      height: result.height.toDouble(),
      name: image.path.split(Platform.pathSeparator).last,
      size: bytes.length,
      uri: image.path,
      width: result.width.toDouble(),
    );
    setState(() {
      attachmentPreview = message;
      file = image;
    });
  }

  // when pressed, it formats the message, sends to socket and calls the api
  void _handleSendPressed(types.PartialText message) async {
    setState(() {
      _isAttachmentUploading = true;
    });
    Map<String, dynamic> formatMessage = formatChatMessage(message);
    _channel.sink.add(json.encode({"message": formatMessage}));
    String lastMessageId = "";
    if (attachmentPreview != null) {
      String uri = await uploadFile(
          file: file!,
          category: 'message',
          categoryId: attachmentPreview!.name);
      Map<String, dynamic> formatImgMessage =
          formatChatMessage(attachmentPreview, uri);

      _channel.sink.add(json.encode({"message": formatImgMessage}));

      lastMessageId = await _messagesApi.saveUserResponse(formatImgMessage);
    }

    // saves the text after the image, the text is linked to the image with lastMessageId
    await _saveResponseAndGetBot(
        {...formatMessage, "lastMessageId": lastMessageId});

    setState(() {
      _isAttachmentUploading = false;
      attachmentPreview = null;
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
        context: context,
        builder: (context) => ImageSourceSheet(
              // includeFile: true,
              onImageSelected: (image) async {
                if (image != null) {
                  Navigator.pop(context);
                  _handleImageSelection(image);
                }
              },
            ));
  }

  /// saves user reponse. Backend handles all bot response / timing.
  Future<void> _saveResponseAndGetBot(Map<String, dynamic> messageMap) async {
    try {
      await _messagesApi.saveUserResponse(messageMap);
      _getMachiResponse();
    } catch (err) {
      Get.snackbar(
        'Error',
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  Future<void> _getMachiResponse() async {
    setState(() {
      isBotTyping = true;
    });
    Map<String, dynamic> message = await _messagesApi.getBotResponse();
    _channel.sink.add(json.encode({"message": message}));
    setState(() {
      isBotTyping = false;
    });
  }

  /// Use only in group chat, otherwise use api calls
  Future<void> _streamBotResponse(Map<String, dynamic> task) async {
    setState(() {
      isBotTyping = true;
    });

    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      var response = await _messagesApi.getTaskResponse(task["task_id"]);
      if (response["status"] == "Success") {
        if (response["result"].containsKey("text")) {
          t.cancel();
          String strResponse = json.encode({"message": response["result"]});
          _onSocketParse(strResponse);
          setState(() {
            isBotTyping = false;
          });
        }
      }
      // try 60 seconds for images
      if (t.tick > 60) {
        t.cancel();
        setState(() {
          isBotTyping = false;
        });
      }
    });
  }

  Future<void> _loadMoreMessage() async {
    try {
      List<types.Message> oldMessages = await _messagesApi.getMessages();
      setState(() {
        _messages.addAll(oldMessages);
      });
    } catch (err) {
      Get.snackbar(
        'Error',
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  void updateFromWidgets(element) {
    setState(() {
      attachmentPreview = element['image'];
    });
  }

  void _showBotInfo() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.9,
            child: BotProfileCard(
              bot: chatController.botController.bot,
              room: _room,
              roomIdx: _roomIdx,
            ));
      },
    );
  }

  void _showFriends() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.9,
            child: FriendListWidget(
              roomIdx: _roomIdx,
            ));
      },
    );
  }

  void _leaveChat(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    confirmDialog(context,
        message: _i18n.translate("leave_chat_warning"),
        negativeAction: () => Navigator.of(context).pop(),
        positiveText: _i18n.translate("leave_chatroom"),
        positiveAction: () async {
          /// Delete
          await _chatroomApi.leaveChatroom(_roomIdx, _room);
          Navigator.of(context).pop();
          Get.delete<MessageController>().then((_) {
            Get.put(MessageController());
          }).then((_) => messageController.offset = 10);
        });
  }
}
