import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/api/py_api.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:fren_app/api/bot_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/loader.dart';

import '../widgets/float_frank.dart';

class BotChatScreen extends StatefulWidget {
  /// Get user object from firebase
  final Bot bot;

  const BotChatScreen({Key? key, required this.bot})
      : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  late types.User _user;
  late types.User _bot;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _replies;
  late AppLocalizations _i18n;

  final _botApi = BotApi();
  final _externalBot = ExternalBotApi();
  bool _isLoading = false;
  bool _isNewMatch = true;

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
    setState(() {_isLoading = true; });

    final _u = UserModel().user;
    _user = types.User(
      id: _u.userId,
      firstName: _u.userFullname,
    );
    _bot = types.User(
      id: widget.bot.botId,
      firstName: widget.bot.name,
    );

    _loadMessages().whenComplete(() => {
      setState(() {
        _isLoading = false;
      })
    });
    _botApi.botMatch(widget.bot.botId, _u.userId);
  }

  Future<void> _loadMessages() async {
    BotPrompt prompt  = await _externalBot.fetchIntroBot(widget.bot.botId, counter);
    types.TextMessage message = createMessage(prompt.text, _bot);

    _addMessage(message);
    if (prompt.hasNext) {
      waitTask(prompt.wait > 0 ? prompt.wait : 10);
      counter++;
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
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
    else if(_isNewMatch){
      return Scaffold(
        appBar: AppBar(
          // Show User profile info
          title: GestureDetector(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0),
              title: Text(widget.bot.name ?? "Bot",
                  style: const TextStyle(fontSize: 24)),
            ),
            onTap: () {
              /// Show bot info
              confirmDialog(context,
                  title: "${_i18n.translate("about")} ${widget.bot.name}",
                  message:
                  "${widget.bot.name} is a ${widget.bot.specialty} bot, using ${widget.bot.model}. \n${widget.bot.about} ",
                  positiveText: _i18n.translate("OK"),
                  positiveAction: () async {
                    // Close the confirm dialog
                    Navigator.of(context).pop();
                  });
            },
          ),
        ),
        body: Center(
          child:       Chat(
            messages: _messages,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            user: _user,
          ),
        ),
        floatingActionButton: const FloatingActionButton(
          onPressed:null,
          backgroundColor: Colors.white,
          child: FrankImage(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      );
    }
    return Scaffold(
      appBar: AppBar(
        // Show User profile info
        title: GestureDetector(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0),
            title: Text(widget.bot.name ?? "Bot",
                style: const TextStyle(fontSize: 24)),
          ),
          onTap: () {
            /// Show bot info
            confirmDialog(context,
                title: "${_i18n.translate("about")} ${widget.bot.name}",
                message:
                "${widget.bot.name} is a ${widget.bot.specialty} bot, using ${widget.bot.model}. \n${widget.bot.about} ",
                positiveText: _i18n.translate("OK"),
                positiveAction: () async {
                  // Close the confirm dialog
                  Navigator.of(context).pop();
                });
          },
        ),
      ),
      body: Center(
        child:       Chat(
          messages: _messages,
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
        ),
      ),
    );
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
    types.TextMessage textMessage  = createMessage(message.text, _user);
    _addMessage(textMessage);
  }

  types.TextMessage createMessage(String text, types.User user) {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );
    return textMessage;
  }

  void waitTask(int seconds) async {
    Timer(Duration(seconds: seconds), () => debugPrint('done waiting'));
  }
}
