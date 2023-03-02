import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/blocked_users_api.dart';
import 'package:fren_app/api/likes_api.dart';
import 'package:fren_app/api/matches_api.dart';
import 'package:fren_app/api/messages_api.dart';
import 'package:fren_app/api/messages_bot.dart';
import 'package:fren_app/api/notifications_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/main.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/profile_screen.dart';
import 'package:fren_app/widgets/chat_message.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:fren_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../api/bot_api.dart';

class BotChatScreen extends StatefulWidget {
  /// Get user object from firebase
  final User user;
  final String botId;

  const BotChatScreen({Key? key, required this.user,  required this.botId}) : super(key: key);

  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  // Variables
  final _textController = TextEditingController();
  final _messagesController = ScrollController();
  final _messagesApi = MessagesBotApi();
  final _botApi = BotApi();
  final _notificationsApi = NotificationsApi();
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _messages;
  bool _isComposing = false;
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  late final Bot _botInfo;
  late final Future<Object> _prompt;

  // Close dialog method
  void _close() => navigatorKey.currentState?.pop();

  void _scrollMessageList() {
    /// Scroll to button
    _messagesController.animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  /// Get image from camera / gallery
  Future<void> _getImage() async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  await _sendMessage(type: 'image', imgFile: image);
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  // Send message
  Future<void> _sendMessage(
      {required String type, String? text, File? imgFile}) async {
    String textMsg = '';
    String imageUrl = '';

    // Check message type
    switch (type) {
      case 'text':
        textMsg = text!;
        break;

      case 'image':
        // Show processing dialog
        _pr.show(_i18n.translate("sending"));

        /// Upload image file
        imageUrl = await UserModel().uploadFile(
            file: imgFile!,
            path: 'uploads/messages',
            userId: UserModel().user.userId);

        _pr.hide();
        break;
    }

    /// Save message for current user
    await _messagesApi.saveMessage(
        type: type,
        fromUserId: UserModel().user.userId,
        senderId: UserModel().user.userId,
        receiverId: widget.user.userId,
        userPhotoLink: widget.user.userProfilePhoto, // other user photo
        userFullName: widget.user.userFullname, // other user ful name
        textMsg: textMsg,
        imgLink: imageUrl,
        isRead: true);

    /// Save copy message for receiver
    await _messagesApi.saveMessage(
        type: type,
        fromUserId: UserModel().user.userId,
        senderId: widget.user.userId,
        receiverId: UserModel().user.userId,
        userPhotoLink: UserModel().user.userProfilePhoto, // current user photo
        userFullName: UserModel().user.userFullname, // current user ful name
        textMsg: textMsg,
        imgLink: imageUrl,
        isRead: false);

    /// Send push notification
    await _notificationsApi.sendPushNotification(
        nTitle: APP_NAME,
        nBody: '${UserModel().user.userFullname}, '
            '${_i18n.translate("sent_a_message_to_you")}',
        nType: 'message',
        nSenderId: UserModel().user.userId,
        nUserDeviceToken: widget.user.userDeviceToken);
  }

  @override
  void initState()  {
    super.initState();
    getBotInfo();
    _prompt = _botApi.getBotIntroPrompt(widget.botId);
  }

  Future<Bot> getBotInfo() async{
    try {
      return await _botApi.getBotInfo(widget.botId);
    } catch(error) {
      print (error);
      rethrow;
    }
  }

  Future<Object> getBotIntro() async{
    return await _botApi.getBotIntroPrompt(widget.botId);
  }

  @override
  void dispose() {
    _messages.drain();
    _textController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context);

    return FutureBuilder<Bot>(
      future: getBotInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LottieLoader();
        } else {
          return Scaffold(
            appBar: AppBar(
              // Show User profile info
              title: GestureDetector(
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 0),
                  title: Text(snapshot.data!.name ?? "Bot",
                      style: const TextStyle(fontSize: 18)),
                ),
                onTap: () {
                  /// Go to profile screen
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(user: widget.user, showButtons: false)));
                },
              ),
              actions: <Widget>[
                /// Actions list
                PopupMenuButton<String>(
                  initialValue: "",
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                   /// view bot info
                    PopupMenuItem(
                        value: "bot_info",
                        child: Row(
                          children: <Widget>[
                            const Icon(Iconsax.information),
                            const SizedBox(width: 5),
                            Text(_i18n.translate("about") + snapshot.data!.name ),
                          ],
                        )),
                  ],
                  onSelected: (val) {
                    /// Control selected value
                    switch (val) {
                      case "bot_info":
                      /// Delete chat
                        confirmDialog(context,
                            title: _i18n.translate("about") + snapshot.data!.name,
                            message: "${snapshot.data!.name} is a ${snapshot.data!.specialty} bot, using ${snapshot.data!.model}. \n"
                                "Find the owner ${snapshot.data!.botOwnerId} ",
                            positiveText: _i18n.translate("OK"),
                            positiveAction: () async {
                              // Close the confirm dialog
                              Navigator.of(context).pop();
                              // Hide progress
                              await _pr.hide();
                            });
                        break;
                    }
                  },
                ),
              ],
            ),
          );
        }
      }
    );

    return Scaffold(
      appBar: AppBar(
        // Show User profile info
        title: GestureDetector(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0),
            title: Text(_botInfo?.name ?? "Bot",
                style: const TextStyle(fontSize: 18)),
          ),
          onTap: () {
            /// Go to profile screen
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(user: widget.user, showButtons: false)));
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          /// how message list
          // Expanded(child: _showMessages()),

          /// Text Composer
          Container(
            color: Colors.grey.withAlpha(50),
            child: ListTile(
                leading: IconButton(
                    icon: const SvgIcon("assets/icons/camera_icon.svg",
                        width: 20, height: 20),
                    onPressed: () async {
                      /// Send image file
                      await _getImage();

                      /// Update scroll
                      _scrollMessageList();
                    }),
                title: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: _i18n.translate("type_a_message"),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                ),
                trailing: IconButton(
                    icon: Icon(Icons.send,
                        color: _isComposing
                            ? Theme.of(context).primaryColor
                            : Colors.grey),
                    onPressed: _isComposing
                        ? () async {
                            /// Get text
                            final text = _textController.text.trim();

                            /// clear input text
                            _textController.clear();
                            setState(() {
                              _isComposing = false;
                            });

                            /// Send text message
                            await _sendMessage(type: 'text', text: text);

                            /// Update scroll
                            _scrollMessageList();
                          }
                        : null)),
          ),
        ],
      ),
    );
  }

  /// Build bubble message
  // Widget _showMessages() {
  //   return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  //       stream: _messages,
  //       builder: (context, snapshot) {
  //         // Check data
  //         if (!snapshot.hasData) {
  //           return const LottieLoader();
  //         }
  //         // else {
  //         //   return ListView.builder(
  //         //       controller: _messagesController,
  //         //       itemCount: snapshot.data!.prompt.length,
  //         //       itemBuilder: (context, index) {
  //         //         print("test");
  //         //         print (snapshot.data!.docs.length);
  //         //         // Get message list
  //         //         final List<DocumentSnapshot<Map<String, dynamic>>> messages =
  //         //             snapshot.data!.docs.reversed.toList();
  //         //         print (messages);
  //         //         // Get message doc map
  //         //         final Map<String, dynamic> msg = messages[index].data()!;
  //         //         print (msg);
  //         //
  //         //         /// Variables
  //         //         bool isUserSender;
  //         //         String userPhotoLink;
  //         //         final bool isImage = msg[MESSAGE_TYPE] == 'image';
  //         //         final String textMessage = msg[MESSAGE_TEXT];
  //         //         final String? imageLink = msg[MESSAGE_IMG_LINK];
  //         //         final String timeAgo =
  //         //             timeago.format(msg[TIMESTAMP].toDate());
  //         //
  //         //         /// Check user id to get info
  //         //         if (msg[USER_ID] == UserModel().user.userId) {
  //         //           isUserSender = true;
  //         //           userPhotoLink = UserModel().user.userProfilePhoto;
  //         //         } else {
  //         //           isUserSender = false;
  //         //           userPhotoLink = widget.user.userProfilePhoto;
  //         //         }
  //         //         // Show chat bubble
  //         //         return ChatMessage(
  //         //           isUserSender: isUserSender,
  //         //           isImage: isImage,
  //         //           userPhotoLink: userPhotoLink,
  //         //           textMessage: textMessage,
  //         //           imageLink: imageLink,
  //         //           timeAgo: timeAgo,
  //         //         );
  //         //       });
  //         // }
  //       });
  // }
}
