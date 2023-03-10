import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/api/messages_api.dart';
import 'package:fren_app/api/py_api.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';

// can't use stateless for Chat class package
class BotChatScreen extends StatefulWidget {
  const BotChatScreen({Key? key})
      : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  final BotController botController = Get.find();
  final ChatController chatController = Get.find();

  late AppLocalizations _i18n;

  late  List<BotPrompt> _prompts;
  final _messagesApi = MessagesApi();
  final _externalBot = ExternalBotApi();
  bool _isLoading = false;
  bool _isAttachmentUploading = false;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  var counter = 0;

  @override
  void initState() {
    super.initState();
    setState(() {_isLoading = true; });
    chatController.onChatLoad();
    setState(() {_isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    /// Initializationd
    _i18n = AppLocalizations.of(context);

    if (_isLoading) {
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
    }
    else {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // Show User profile info
          title: GestureDetector(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0),
              title: Text(botController.bot.name ?? "Bot",
                  style: const TextStyle(fontSize: 24)),
            ),
            onTap: () {
              /// Show bot info
              confirmDialog(context,
                  title: "${_i18n.translate("about")} ${botController.bot.name}",
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
        body: StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: _messagesApi.getChatMessages(),
            builder: (context, snapshot) {
              print (snapshot.data);
              if (!snapshot.hasData) {
                return const Frankloader();
              } else {
                return Chat(
                    theme: const DefaultChatTheme(
                      inputBackgroundColor: Colors.red,
                    ),
                    isAttachmentUploading: _isAttachmentUploading,
                    messages: snapshot!.data!,
                    onAttachmentPressed: _handleAtachmentPressed,
                    onMessageTap: _handleMessageTap,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: _handleSendPressed,
                    user: chatController.chatUser
                );
              }
            }
          ),
        );
    }
  }

  Future<void> _saveMessage(message, user) async {
    // save as types.User
    await _messagesApi.saveChatMessage(message, user);
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
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cancel'),
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
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          // mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        // FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _saveMessage(message, chatController.chatUser);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
          _saveMessage(updatedMessage, chatController.chatUser);
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          _saveMessage(updatedMessage, chatController.chatUser);
        }
      }
      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final updatedMessage = message.copyWith(previewData: previewData);
    _saveMessage(updatedMessage, chatController.chatUser);
  }

  void _handleSendPressed(types.PartialText message) {
    _saveMessage(message, chatController.chatUser);
    _callAPI(message.text);
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  Future<void> _callAPI(String message) async {
    /// call bot model api
    _externalBot.getBotPrompt(botController.bot.domain, botController.bot.model, message).then((res){
      types.PartialText textMessage =  createMessage(res, chatController.chatBot);
      _saveMessage(textMessage, chatController.chatBot);
    });
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

