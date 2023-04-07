import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/helpers/message_format.dart';
import 'package:fren_app/widgets/bot/bot_profile.dart';
import 'package:fren_app/widgets/bot/bot_timer.dart';
import 'package:fren_app/widgets/friend_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
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
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/widgets/bot/tiny_bot.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class BotChatScreen extends StatefulWidget {
  const BotChatScreen({Key? key}) : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  final AppHelper _appHelper = AppHelper();
  final BotController botController = Get.find();
  final ChatController chatController = Get.find();
  final MessageController messageController = Get.find();

  late List<types.Message> _messages = [];

  late types.User _user;
  late AppLocalizations _i18n;
  late WebSocketChannel _channel;
  late Chatroom _room;
  late int _roomIdx;
  final _messagesApi = MessageMachiApi();
  final _chatroomApi = ChatroomMachiApi();
  bool _isAttachmentUploading = false;
  bool isLoading = false;
  bool isBotSleeping = false;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  Future<void> _listenSocket() async {
    debugPrint("Initiating to socket");

    final _authApi = AuthApi();
    Map<String, dynamic> headers = await _authApi.getHeaders();
    final Uri wsUrl = Uri.parse('${SOCKET_WS}messages/${_room.chatroomId}');
    _channel = WebSocketChannel.connect(wsUrl);
    _channel.sink.add(json.encode({"token": headers}));
    _channel.stream
        .listen(
      (_) {},
      onError: (error) => showScaffoldMessage(
          message: _i18n.translate("an_error_has_occurred"),
          bgcolor: APP_ERROR),
    )
        .onData((data) {
      _onSocketParse(data);
    });
  }

  void _onSocketParse(String message) {
    Map<String, dynamic> decodeData = json.decode(message);
    types.Message newMessage = oldMessageTypes(decodeData["message"]);
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
      return const Frankloader();
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
            onSendPressed: _handleSendPressed,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            user: _user),
      );
    }
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
      maxWidth: 256,
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

      // _callAPI(message);
    }
  }

  // when pressed, it formats the message, sends to socket and calls the api
  void _handleSendPressed(types.PartialText message) {
    Map<String, dynamic> formatMessage = formatChatMessage(message);
    _channel.sink.add(json.encode({"message": formatMessage}));
    _callAPI(formatMessage);
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

  /// saves user reponse. Backend handles all bot response / timing.
  Future<void> _callAPI(Map<String, dynamic> messageMap) async {
    setState(() {
      _isAttachmentUploading = true;
    });
    try {
      final task = await _messagesApi.saveUserResponse(messageMap);
      _streamBotResponse(task);
    } catch (err) {
      showScaffoldMessage(
          message: _i18n.translate("an_error_has_occurred"),
          bgcolor: APP_ERROR);
    }

    setState(() {
      _isAttachmentUploading = false;
    });
  }

  // Call task id every 1 second to get bot response
  Future<void> _streamBotResponse(Map<String, dynamic> task) async {
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      var response = await _messagesApi.getTaskResponse(task["task_id"]);
      if (response["status"] == "Success") {
        t.cancel();
        if (response["result"].containsKey("text")) {
          String strResponse = json.encode({"message": response["result"]});
          _onSocketParse(strResponse);
        }
      }
      // try 5 times
      if (t.tick == 5) {
        t.cancel();
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
      showScaffoldMessage(
          message: _i18n.translate("an_error_has_occurred"),
          bgcolor: APP_ERROR);
    }
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
