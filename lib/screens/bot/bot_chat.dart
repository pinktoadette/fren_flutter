import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/api/machi/gallery_api.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/message_format.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/bot/bot_profile.dart';
import 'package:machi_app/widgets/chat/add_message_to_storyboard.dart';
import 'package:machi_app/widgets/chat/header_input.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:machi_app/widgets/subscribe/subscribe_how_to_art.dart';
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:machi_app/api/machi/message_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/message_controller.dart';
import 'package:machi_app/datas/chatroom.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';

import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:machi_app/helpers/create_uuid.dart';

class BotChatScreen extends StatefulWidget {
  const BotChatScreen({Key? key}) : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  final BotController botController = Get.find(tag: 'bot');
  final ChatController chatController = Get.find(tag: 'chatroom');
  final MessageController messageController = Get.find(tag: 'message');
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');
  late final List<types.Message> _messages = [];

  late types.User _user;
  late AppLocalizations _i18n;
  late Chatroom _room;

  late int _roomIdx;
  final _messagesApi = MessageMachiApi();
  final _chatroomApi = ChatroomMachiApi();
  bool _isAttachmentUploading = false;
  bool isLoading = false;
  bool isLastPage = false;

  late FocusNode _focusNode;
  // bool? isBotTyping;
  File? file;
  bool _hasNewMessages = false;
  String? _setTags;
  types.PartialImage? attachmentPreview;

  final TextMessageOptions textMessageOptions = const TextMessageOptions(
    isTextSelectable: true,
  );

  @override
  void initState() {
    super.initState();
    // get the room
    final args = Get.arguments;
    _room = args["room"];
    _user = chatController.chatUser;
    _roomIdx = args["index"];

    // get the messages loaded from the room
    _messages.addAll(_room.messages);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // _player.dispose();
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initializationd
    _i18n = AppLocalizations.of(context);

    if (isLoading) {
      return const Frankloader();
    } else {
      return WillPopScope(
          onWillPop: () {
            _leaveChatroom();
            return Future.value(true);
          },
          child: Scaffold(
              appBar: AppBar(
                centerTitle: false,
                leading: BackButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    _leaveChatroom();
                  },
                ),
                titleSpacing: 0,
                title: GestureDetector(
                  child: Obx(() => Text(botController.bot.name,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.displayMedium)),
                  onTap: () {
                    /// Show bot info
                    _showBotInfo();
                  },
                ),
                actions: const [SubscribeHowToArt(), SubscribeTokenCounter()],
              ),
              body: Chat(
                  isLastPage: isLastPage,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  inputHeader: Obx(() => CustomHeaderInputWidget(
                      onUpdateWidget: (e) {
                        setState(() {
                          attachmentPreview = e['image'];
                        });
                      },
                      onImageSelect: (value) {
                        setState(() {
                          _setTags = value == _setTags ? null : value;
                        });
                      },
                      onTagChange: _setTags,
                      isBotTyping: chatController.currentRoom.isTyping,
                      attachmentPreview: attachmentPreview)),
                  theme: DefaultChatTheme(
                      sentMessageBodyTextStyle:
                          const TextStyle(color: Colors.black),
                      inputBackgroundColor: APP_INPUT_COLOR,
                      inputTextStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      primaryColor: Theme.of(context).colorScheme.secondary,
                      sendButtonIcon: Icon(Iconsax.send_2,
                          color: Theme.of(context).colorScheme.primary),
                      backgroundColor:
                          Theme.of(context).colorScheme.background),
                  onEndReached: _loadMoreMessage, //get more messages on top
                  showUserNames: true,
                  showUserAvatars: true,
                  isAttachmentUploading: _isAttachmentUploading,
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  onAvatarTap: (messageUser) async {
                    if (!messageUser.id.contains("Machi_")) {
                      final user =
                          await UserModel().getUserObject(messageUser.id);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: user)));
                    }
                  },
                  onAttachmentPressed: _handleAttachmentPressed,
                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  listFooterWidgetBuilder: (message) => _listWidget(message),
                  user: _user)));
    }
  }

  List<Widget> _listWidget(types.Message message) => [
        TextButton(
          onPressed: () {
            _handleMessageFooterTap(message);
          },
          child: Container(
            padding: const EdgeInsets.all(3),
            child: const Icon(Iconsax.book, size: 14),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (message.type == types.MessageType.image) {
              final _galleryApi = GalleryApi();
              await _galleryApi.addUserGallery(messageId: message.id);
              Get.snackbar(
                _i18n.translate("success"),
                _i18n.translate("story_added"),
                snackPosition: SnackPosition.TOP,
                backgroundColor: APP_SUCCESS,
              );
            } else {
              Get.snackbar(
                _i18n.translate("error"),
                _i18n.translate("add_images_only_collection"),
                snackPosition: SnackPosition.TOP,
                backgroundColor: APP_ERROR,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(3),
            child: const Icon(Iconsax.gallery_add, size: 14),
          ),
        ),
        TextButton(
          onPressed: () {
            String? encodeQueryParameters(Map<String, String> params) {
              return params.entries
                  .map((MapEntry<String, String> e) =>
                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                  .join('&');
            }

            dynamic msg = message;

            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: '',
              query: encodeQueryParameters(<String, String>{
                'subject': "${msg.author.firstName} @ Machi",
                'body':
                    msg.type == types.MessageType.text ? msg.text : "Not a text"
              }),
            );

            launchUrl(emailLaunchUri);
          },
          child: Container(
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.email_outlined, size: 14),
          ),
        ),
      ];

  void _handleMessageFooterTap(types.Message message) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => FractionallySizedBox(
          heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
          child: DraggableScrollableSheet(
            snap: true,
            initialChildSize: 1,
            minChildSize: 0.9,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: AddChatMessageToBoard(
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
    // for audio
    // if (message is types.TextMessage) {
    //   String key = await _streamApi.getAuthToken();
    //   http.StreamedResponse streamedResponse =
    //       await _streamApi.streamAudio(key, message.text, 'eastus');
    //   Uint8List data = await streamedResponse.stream.toBytes();
    //   await _player.setAudioSource(BytesSource(data));
    //   _player.play();
    // }
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
      _hasNewMessages = true;
    });

    String lastMessageId = "";
    if (attachmentPreview != null) {
      try {
        String uri = await uploadFile(
            file: file!,
            category: UPLOAD_PATH_MESSAGE,
            categoryId: createUUID());
        Map<String, dynamic> formatImgMessage = chatController.sendMessage(
            room: _room, partialMessage: attachmentPreview, uri: uri);
        _addMessages(formatImgMessage);
        lastMessageId = await _messagesApi.saveUserResponse(
            messageMap: {...formatImgMessage, CHAT_TEXT: ""}, tags: _setTags);
      } catch (err, s) {
        Get.snackbar(
          _i18n.translate("error"),
          _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
        );
        setState(() {
          _isAttachmentUploading = false;
          attachmentPreview = null;
        });
        await FirebaseCrashlytics.instance.recordError(err, s,
            reason: 'image uploaded and has error ${err.toString()}',
            fatal: true);
        return;
      } finally {
        setState(() {
          attachmentPreview = null;
        });
      }
    }

    Map<String, dynamic> newMessage =
        chatController.sendMessage(room: _room, partialMessage: message);
    // saves the text after the image, the text is linked to the image with lastMessageId
    await _saveResponseAndGetBot(
        {...newMessage, "lastMessageId": lastMessageId});
    _addMessages(newMessage);
    setState(() {
      _isAttachmentUploading = false;
    });
    _focusNode.unfocus();
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
              onGallerySelected: (imageUrl) {
                types.PartialImage message = types.PartialImage(
                    height: 516,
                    name: imageUrl,
                    size: imageUrl.length,
                    uri: imageUrl,
                    width: 516);
                _handleSendPressed(message as types.PartialText);
              },
            ));
  }

  /// saves user reponse. Backend handles all bot response / timing.
  Future<void> _saveResponseAndGetBot(Map<String, dynamic> messageMap) async {
    try {
      await _messagesApi.saveUserResponse(
          messageMap: messageMap, tags: _setTags);
      _getMachiResponse();
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error saving and getting bot response', fatal: true);
    }
  }

  Future<void> _getMachiResponse() async {
    try {
      chatController.typingStatus(room: _room, isTyping: true);
      // Use Future.delayed for lazy loading
      await Future.delayed(const Duration(seconds: 1));

      Map<String, dynamic> newMessage =
          await chatController.getMachiResponse(room: _room);

      _addMessages(newMessage);
    } on DioException catch (error) {
      String errorMessage = "Sorry, got an error 😕. Try again.";

      if (error.response != null &&
          error.response is Map<String, dynamic> &&
          error.response?.data) {
        errorMessage = error.response!.data["message"];
      }
      dynamic response = {
        CHAT_AUTHOR_ID: _room.bot.botId,
        CHAT_AUTHOR: _room.bot.name,
        BOT_ID: _room.bot.botId,
        CHAT_MESSAGE_ID: createUUID(),
        CHAT_TEXT: errorMessage,
        CHAT_TYPE: "text",
        CREATED_AT: getDateTimeEpoch()
      };
      _addMessages(response);
    } finally {
      chatController.typingStatus(room: _room, isTyping: false);
    }

    if (_setTags != null) {
      subscribeController.getCredits();
    }
    if (mounted) {
      setState(() {
        _setTags = null;
      });
    }
  }

  Future<void> _loadMoreMessage() async {
    try {
      List<types.Message> oldMessages = await _messagesApi.getMessages();

      setState(() {
        _messages.addAll(oldMessages);
        isLastPage = oldMessages.isEmpty;
      });
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error loading more messages in infinite scroll',
          fatal: true);
    }
  }

  void _showBotInfo() {
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 400 / height,
            child: BotProfileCard(
              bot: botController.bot,
              room: _room,
              roomIdx: _roomIdx,
            ));
      },
    );
  }

  // void _showFriends() {
  //   if (_room.users.length >= 2) {
  //     confirmDialog(context,
  //         message: _i18n.translate("friend_invite_limit_chat"),
  //         positiveText: _i18n.translate("OK"), positiveAction: () {
  //       Navigator.of(context).pop();
  //     });
  //   } else {
  //     showModalBottomSheet<void>(
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) {
  //         return FractionallySizedBox(
  //             heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
  //             child: FriendListWidget(
  //               roomIdx: _roomIdx,
  //             ));
  //       },
  //     );
  //   }
  // }

  /// DO NOT DELETE
  /// tHIS IS USED ON RABBIT
  // Future<void> _streamBotResponse(Map<String, dynamic> task) async {
  //   setState(() {
  //     isBotTyping = true;
  //   });

  //   Timer.periodic(const Duration(seconds: 1), (Timer t) async {
  //     var response = await _messagesApi.getTaskResponse(task["task_id"]);
  //     if (response["status"] == "Success") {
  //       if (response["result"].containsKey("text")) {
  //         t.cancel();
  //         String strResponse = json.encode({"message": response["result"]});
  //         _onSocketParse(strResponse);
  //         setState(() {
  //           isBotTyping = false;
  //         });
  //       }
  //     }
  //     // try 60 seconds for images
  //     if (t.tick > 60) {
  //       t.cancel();
  //       setState(() {
  //         isBotTyping = false;
  //       });
  //     }
  //   });
  // }

  void _leaveChatroom() async {
    // if there are no messages, remove from roomList
    if ((_messages.isEmpty) & (chatController.currentRoom.users.length == 1)) {
      chatController.removeEmptyRoomfromList();
    }
    if (_hasNewMessages == true) {
      /// mark as read when clicked when exit
      await _chatroomApi.markAsRead(chatController.currentRoom.chatroomId);
      Chatroom room =
          chatController.currentRoom.copyWith(read: true, messages: _messages);
      chatController.updateRoom(room);

      chatController.sortRoomExit();
    }
    messageController.offset = 1;

    botController.fetchCurrentBot(DEFAULT_BOT_ID);

    Get.back();
  }

  void _addMessages(Map<String, dynamic> message) {
    types.Message newMessage = messageFromJson(message);
    if (mounted) {
      setState(() {
        _messages.insert(0, newMessage);
      });
    }
  }
}
