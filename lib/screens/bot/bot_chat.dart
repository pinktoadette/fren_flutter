import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/api/machi/message_api.dart';
import 'package:fren_app/api/messages_api.dart';
import 'package:fren_app/api/machi/bot_api.dart';
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

// can't use stateless for Chat class package
class BotChatScreen extends StatefulWidget {
  const BotChatScreen({Key? key}) : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  final BotController botController = Get.find();
  final ChatController chatController = Get.find();

  late AppLocalizations _i18n;

  // no streams, just get list and push to state
  List<types.Message> _messages = [];
  final _messagesApi = MessageApi();
  // final _botApi = BotApi();
  bool _isLoading = false;
  bool _isAttachmentUploading = false;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  var counter = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    chatController.onChatLoad();
    setState(() {
      _isLoading = false;
    });
    _fetchUserMessages();
  }

  Future<void> _fetchUserMessages() async {
    List<types.Message> message = await _messagesApi.getMessages();
    setState(() {
      _messages = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initializationd
    _i18n = AppLocalizations.of(context);

    if (_isLoading ) {
      debugPrint("loading chat bot");
      return Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [Frankloader()],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
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
                      "${botController.bot.name} is using ${botController.bot.model}. \n${botController.bot.about} ",
                  positiveText: _i18n.translate("OK"),
                  positiveAction: () async {
                // Close the confirm dialog
                Navigator.of(context).pop();
              });
            },
          ),
        ),
        body: Chat(
            showUserNames: true,
            onMessageLongPress: _handleLongPress,
            isAttachmentUploading: _isAttachmentUploading,
            messages: _messages,
            onAttachmentPressed: _handleAtachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            user: chatController.chatUser),

        // StreamBuilder<List<types.Message>>(
        //     initialData: const [],
        //     stream: _messages,
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) {
        //         return const Frankloader();
        //       } else {
        //         return Chat(
        //             showUserNames: true,
        //             onMessageLongPress: _handleLongPress,
        //             isAttachmentUploading: _isAttachmentUploading,
        //             messages: snapshot.data!,
        //             onAttachmentPressed: _handleAtachmentPressed,
        //             onMessageTap: _handleMessageTap,
        //             onPreviewDataFetched: _handlePreviewDataFetched,
        //             onSendPressed: _handleSendPressed,
        //             user: chatController.chatUser);
        //       }
        //     }),
      );
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }


  void _handleLongPress(BuildContext _, types.Message message) {

    showModalBottomSheet(context: context, builder: (context)=> ShareMessage( message: message ));
    //
    // if (message.author.id == chatController.chatUser.id) {
    //   showDialog(context: context, builder: (context)=> Frankloader());
    // }
  }

  void _handleAtachmentPressed() {
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
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Photo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //     _handleFileSelection();
              //   },
              //   child: const Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text('File', style: TextStyle(color: Colors.white),),
              //   ),
              // ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

      _addMessage(message);
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

      await OpenFilex.open(localPath);
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
    final textMessage = types.TextMessage(
      author: chatController.chatUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    _callAPI(message);
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  /// call bot model api
  Future<void> _callAPI(dynamic message) async {
    // hacky way - chat_ui package is not updated from repo for typing indicator
    setState(() {
      _isAttachmentUploading = true;
    });
    _messagesApi
        .saveChatMessage(message)
        .then((res) {
          // returns bot response
        return res;
    }).catchError((error) {
      showScaffoldMessage(
          context: context,
          message: _i18n.translate("an_error_has_occurred"),
          bgcolor: Colors.pinkAccent);
    }).whenComplete(() {
      setState(() {
        _isAttachmentUploading = false;
      });
    });;
  }

  types.PartialText createMessage(String text, types.User user) {
    final textMessage = types.PartialText(
      text: text,
    );
    return textMessage;
  }

  void waitTask(int seconds) async {
    Timer(Duration(seconds: seconds), () => debugPrint('done waiting'));
  }
}
