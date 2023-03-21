// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fren_app/api/blocked_users_api.dart';
// import 'package:fren_app/api/likes_api.dart';
// import 'package:fren_app/api/matches_api.dart';
// import 'package:fren_app/api/messages_api.dart';
// import 'package:fren_app/api/notifications_api.dart';
// import 'package:fren_app/constants/constants.dart';
// import 'package:fren_app/datas/user.dart';
// import 'package:fren_app/dialogs/common_dialogs.dart';
// import 'package:fren_app/dialogs/progress_dialog.dart';
// import 'package:fren_app/helpers/app_localizations.dart';
// import 'package:fren_app/main.dart';
// import 'package:fren_app/models/user_model.dart';
// import 'package:fren_app/screens/user/profile_screen.dart';
// import 'package:fren_app/widgets/chat_message.dart';
// import 'package:fren_app/widgets/image_source_sheet.dart';
// import 'package:fren_app/widgets/loader.dart';
// import 'package:fren_app/widgets/show_scaffold_msg.dart';
// import 'package:fren_app/widgets/svg_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeago;
//
// class ChatScreen extends StatefulWidget {
//
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//
//   final _textController = TextEditingController();
//   final _notificationsApi = NotificationsApi();
//   final _messagesController = ScrollController();
//   late AppLocalizations _i18n;
//   bool _isUploading = false;
//   bool _isComposing = false;
//
//   void _scrollMessageList() {
//     /// Scroll to button
//     _messagesController.animateTo(0.0,
//         duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
//   }
//   // Send message
//   Future<void> _sendMessage(
//       {required String type, String? text, File? imgFile}) async {
//     String textMsg = '';
//     String imageUrl = '';
//
//
//     // Check message type
//     switch (type) {
//       case 'text':
//         textMsg = text!;
//         break;
//
//       case 'image':
//       // Show processing dialog
//         _isUploading = true;
//
//         /// Upload image file
//         imageUrl = await UserModel().uploadFile(
//             file: imgFile!,
//             path: 'uploads/messages',
//             userId: UserModel().user.userId);
//
//         _isUploading = false;
//         break;
//     }
//
//     /// Save message for current user
//
//
//     /// Send push notification
//     /// We will need to loop the people in here and send push
//     // await _notificationsApi.sendPushNotification(
//     //     nTitle: APP_NAME,
//     //     nBody: '${UserModel().user.userFullname}, '
//     //         '${_i18n.translate("sent_a_message_to_you")}',
//     //     nType: 'message',
//     //     nSenderId: UserModel().user.userId,
//     //     nUserDeviceToken: widget.user.userDeviceToken);
//   }
//
//   Future<void> _getImage() async {
//     await showModalBottomSheet(
//         context: context,
//         backgroundColor: Colors.transparent,
//         builder: (context) => ImageSourceSheet(
//           onImageSelected: (image) async {
//             if (image != null) {
//               await _sendMessage(type: 'image', imgFile: image);
//               // close modal
//               Navigator.of(context).pop();
//             }
//           },
//         ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     /// Initialization
//     _i18n = AppLocalizations.of(context);
//
//     return Column(
//         children: <Widget>[
//           /// how message list
//           Expanded(child: _showMessages()),
//
//           /// Text Composer
//           Container(
//             color: Colors.grey.withAlpha(50),
//             child: ListTile(
//                 title: TextField(
//                   controller: _textController,
//                   minLines: 1,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                       hintText: _i18n.translate("type_a_message"),
//                       border: InputBorder.none),
//                   onChanged: (text) {
//                     setState(() {
//                       _isComposing = text.isNotEmpty;
//                     });
//                   },
//                 ),
//                 trailing: IconButton(
//                     icon: Icon(Icons.send,
//                         color: _isComposing
//                             ? Theme.of(context).primaryColor
//                             : Colors.grey),
//                     onPressed: _isComposing
//                         ? () async {
//                       /// Get text
//                       final text = _textController.text.trim();
//
//                       /// clear input text
//                       _textController.clear();
//                       setState(() {
//                         _isComposing = false;
//                       });
//
//                       /// Send text message
//                       await _sendMessage(type: 'text', text: text);
//
//                       /// Update scroll
//                       _scrollMessageList();
//                     }
//                         : null)),
//           ),
//         ],
//       );
//   }
//
//
//   /// Build bubble message
//   Widget _showMessages() {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: _messages,
//         builder: (context, snapshot) {
//           // Check data
//           if (!snapshot.hasData) {
//             return const Frankloader();
//           } else {
//             return ListView.builder(
//                 controller: _messagesController,
//                 reverse: true,
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   // Get message list
//                   final List<DocumentSnapshot<Map<String, dynamic>>> messages =
//                   snapshot.data!.docs.reversed.toList();
//                   // Get message doc map
//                   final Map<String, dynamic> msg = messages[index].data()!;
//
//                   /// Variables
//                   bool isUserSender;
//                   String userPhotoLink;
//                   final bool isImage = msg[MESSAGE_TYPE] == 'image';
//                   final String textMessage = msg[MESSAGE_TEXT];
//                   final String? imageLink = msg[MESSAGE_IMG_LINK];
//                   final String timeAgo =
//                   timeago.format(msg[TIMESTAMP].toDate());
//
//                   /// Check user id to get info
//                   if (msg[USER_ID] == UserModel().user.userId) {
//                     isUserSender = true;
//                     userPhotoLink = UserModel().user.userProfilePhoto;
//                   } else {
//                     isUserSender = false;
//                     // userPhotoLink = widget.user.userProfilePhoto;
//                   }
//                   // Show chat bubble
//                   return ChatMessage(
//                     isUserSender: isUserSender,
//                     isImage: isImage,
//                     textMessage: textMessage,
//                     imageLink: imageLink,
//                     timeAgo: timeAgo,
//                   );
//                 });
//           }
//         });
//   }
// }