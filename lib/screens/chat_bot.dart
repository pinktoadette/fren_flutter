import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../api/bot_api.dart';
import '../api/messages_bot.dart';
import '../datas/bot.dart';
import '../datas/user.dart';
import '../dialogs/common_dialogs.dart';
import '../helpers/app_localizations.dart';
import '../widgets/loader.dart';

class BotChatScreen extends StatefulWidget {
  /// Get user object from firebase
  final User user;
  final String botId;

  const BotChatScreen({Key? key, required this.user, required this.botId})
      : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  late types.User _user;
  late types.User _bot;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _replies;
  late AppLocalizations _i18n;
  late final List<dynamic> _prompt;
  final _messagesApi = MessagesBotApi();
  final _botApi = BotApi();
  late Bot _botInfo;
  final List<types.Message> _messages = [];
  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
    // void Function(String)? onLinkPressed,
    // bool openOnPreviewImageTap = false,
    // bool openOnPreviewTitleTap = false,
    //     List<MatchText> matchers = const [],
  );
  var counter = 0;

  @override
  void initState() {
    super.initState();
    _user = types.User(
      id: widget.user.userId,
      firstName: widget.user.userFullname,
    );
    _getInfo();
    _botApi.initalChatBot(widget.botId, widget.user.userId);
  }

  Future<Object> getChat() async {
    try {
      return _botInfo;
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  void _getInfo() async {
    Future<List> p = _botApi.getBotIntroPrompt(widget.botId);
    _prompt = await p;

    _botInfo = await _botApi.getBotInfo(widget.botId);
    _bot = types.User(
      id: _botInfo.botId,
      firstName: _botInfo.name,
    );
    _loadMessages();
  }

  void _loadMessages() async {
    types.Message message = createMessage(_prompt[counter], _bot);
    _addMessage(message);
    waitTask(10);
    while(counter < 3) {
      _loadMessages();
    }
    counter++;
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        // Show User profile info
        title: GestureDetector(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0),
            title: Text(_botInfo!.name ?? "Bot",
                style: const TextStyle(fontSize: 24)),
          ),
          onTap: () {
            /// Show bot info
            confirmDialog(context,
                title: _i18n.translate("about") + _botInfo!.name,
                message:
                "${_botInfo!.name} is a ${_botInfo?.specialty} bot, using ${_botInfo?.model}. \n${_botInfo?.about} ",
                positiveText: _i18n.translate("OK"),
                positiveAction: () async {
                  // Close the confirm dialog
                  Navigator.of(context).pop();
                });
          },
        ),
      ),
      body: Chat(
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),

      // Chat(
      //   messages: _messages,
      //   onAttachmentPressed: _handleAttachmentPressed,
      //   onMessageTap: _handleMessageTap,
      //   onPreviewDataFetched: _handlePreviewDataFetched,
      //   onSendPressed: _handleSendPressed,
      //   showUserAvatars: true,
      //   showUserNames: true,
      //   user: _user,
      // ),
    );
    // return FutureBuilder<Object>(
    //     future: getChat(),
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData) {
    //         return const LottieLoader();
    //       } else {
    //         return Scaffold(
    //           appBar: AppBar(
    //             // Show User profile info
    //             title: GestureDetector(
    //               child: ListTile(
    //                 contentPadding: const EdgeInsets.only(left: 0),
    //                 title: Text(_botInfo!.name ?? "Bot",
    //                     style: const TextStyle(fontSize: 24)),
    //               ),
    //               onTap: () {
    //                 /// Show bot info
    //                 confirmDialog(context,
    //                     title: _i18n.translate("about") + _botInfo!.name,
    //                     message:
    //                         "${_botInfo!.name} is a ${_botInfo?.specialty} bot, using ${_botInfo?.model}. \n${_botInfo?.about} ",
    //                     positiveText: _i18n.translate("OK"),
    //                     positiveAction: () async {
    //                   // Close the confirm dialog
    //                   Navigator.of(context).pop();
    //                 });
    //               },
    //             ),
    //           ),
    //           body: Chat(
    //             messages: _messages,
    //             onAttachmentPressed: _handleAttachmentPressed,
    //             onMessageTap: _handleMessageTap,
    //             onPreviewDataFetched: _handlePreviewDataFetched,
    //             onSendPressed: _handleSendPressed,
    //             showUserAvatars: true,
    //             showUserNames: true,
    //             user: _user,
    //           ),
    //
    //           // Chat(
    //           //   messages: _messages,
    //           //   onAttachmentPressed: _handleAttachmentPressed,
    //           //   onMessageTap: _handleMessageTap,
    //           //   onPreviewDataFetched: _handlePreviewDataFetched,
    //           //   onSendPressed: _handleSendPressed,
    //           //   showUserAvatars: true,
    //           //   showUserNames: true,
    //           //   user: _user,
    //           // ),
    //         );
    //       }
    //     });
  }

  Future<void> _addMessage(types.Message message) async {
    setState(() {
      _messages.insert(0, message);
    });
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
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
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
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    types.TextMessage textMessage;
    if (counter > 10) {
      textMessage = createMessage(message.text, _user);
    } else {
      String text = "Hold on. \n" + _prompt[counter];
      textMessage = createMessage(text, _bot);
    }
    _addMessage(textMessage);
  }

  types.TextMessage createMessage(String text, types.User user) {
    return types.TextMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: text);
  }

  void waitTask(int seconds) async {
    Timer(Duration(seconds: seconds), () => print('done'));
  }
}
