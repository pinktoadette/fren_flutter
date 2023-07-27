// // ignore_for_file: constant_identifier_names

// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:machi_app/api/machi/interactive_api.dart';
// import 'package:machi_app/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:machi_app/datas/interactive.dart';
// import 'package:machi_app/helpers/app_localizations.dart';
// import 'package:machi_app/helpers/create_uuid.dart';
// import 'package:machi_app/helpers/uploader.dart';
// import 'package:machi_app/screens/interactive/interactive_board_page.dart';
// import 'package:machi_app/widgets/button/loading_button.dart';
// import 'package:machi_app/widgets/image/image_source_sheet.dart';
// import 'package:machi_app/widgets/storyboard/my_items/list_my_board.dart';

// enum Mode { INTERACTIVE, BOARD }

// /// Creator can create from
// /// 1. prompt, 2. board
// class ConfirmPrompt extends StatefulWidget {
//   const ConfirmPrompt({Key? key}) : super(key: key);

//   @override
//   _ConfirmPromptState createState() => _ConfirmPromptState();
// }

// class _ConfirmPromptState extends State<ConfirmPrompt> {
//   late AppLocalizations _i18n;
//   File? attachmentPreview;
//   String? galleryImageUrl;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _i18n = AppLocalizations.of(context);

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Container(
//             padding: const EdgeInsets.only(left: 15, top: 15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _i18n.translate("post_create"),
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 5),
//           SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             physics: const ScrollPhysics(),
//             child: _initialSelection(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _initialSelection() {
//     return Column(
//       children: [
//         Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                     side: BorderSide(
//                         color: _selectedMode == Mode.INTERACTIVE
//                             ? APP_ACCENT_COLOR
//                             : APP_MUTED_COLOR)),
//                 onPressed: () => setState(() {
//                   _selectedMode = Mode.INTERACTIVE;
//                 }),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Text(_i18n.translate("post_interactive_button")),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                     side: BorderSide(
//                         color: _selectedMode == Mode.BOARD
//                             ? APP_ACCENT_COLOR
//                             : APP_MUTED_COLOR)),
//                 onPressed: () => setState(() {
//                   _selectedMode = Mode.BOARD;
//                 }),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Text(_i18n.translate("post_board_button")),
//                 ),
//               )
//             ]),
//         const SizedBox(
//           height: 10,
//         ),
//         Padding(
//             padding: const EdgeInsets.only(left: 20, right: 20),
//             child: _selectedMode == Mode.INTERACTIVE
//                 ? Text(
//                     _i18n.translate("post_interactive_info"),
//                     style: Theme.of(context).textTheme.labelSmall,
//                   )
//                 : _selectedMode == Mode.BOARD
//                     ? Text(
//                         _i18n.translate("post_board_info"),
//                         style: Theme.of(context).textTheme.labelSmall,
//                       )
//                     : const SizedBox.shrink()),
//         _promptModeDisplay()
//       ],
//     );
//   }

//   Widget _promptModeDisplay() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//                 padding: const EdgeInsets.only(
//                   top: 10,
//                   left: 20,
//                 ),
//                 child: attachmentPreview != null || galleryImageUrl != null
//                     ? _attachmentPreview()
//                     : Container(
//                         height: 70,
//                         width: 70,
//                         margin: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(10)),
//                             border: Border.all(
//                                 width: 1,
//                                 color: Colors.grey,
//                                 strokeAlign: BorderSide.strokeAlignCenter)),
//                         child: IconButton(
//                             onPressed: () {
//                               _addImage();
//                             },
//                             icon: const Icon(Iconsax.image)),
//                       )),
//           ],
//         ),
//         Padding(
//             padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
//             child: TextFormField(
//               style: const TextStyle(fontSize: 16),
//               textCapitalization: TextCapitalization.sentences,
//               controller: _postTextController,
//               decoration: InputDecoration(
//                   hintText: _i18n.translate("post_interactive_hint")),
//               maxLines: 10,
//               maxLength: 300,
//             )),
//         Align(
//           alignment: Alignment.center,
//           child: ElevatedButton.icon(
//               icon:
//                   isLoading ? loadingButton(size: 16) : const SizedBox.shrink(),
//               onPressed: () {
//                 _publishInteractive();
//               },
//               label: Text(_i18n.translate("publish"))),
//         )
//       ],
//     );
//   }

//   Widget _attachmentPreview() {
//     // @todo remove. duplicate fuction
//     return Stack(
//       children: <Widget>[
//         SizedBox(
//           height: 70,
//           width: 70,
//           child: ClipRRect(
//               borderRadius: BorderRadius.circular(10), // Image border
//               child: SizedBox.fromSize(
//                   size: const Size.fromRadius(48), // Image radius
//                   child: AspectRatio(
//                     aspectRatio: 1.5,
//                     child: galleryImageUrl != null
//                         ? CachedNetworkImage(
//                             errorWidget: (context, url, error) =>
//                                 const Icon(Icons.error),
//                             progressIndicatorBuilder: (context, url,
//                                     progress) =>
//                                 loadingButton(size: 16, color: Colors.black),
//                             imageUrl: galleryImageUrl!,
//                             fadeInDuration: const Duration(seconds: 1),
//                             width: 70,
//                             height: 70,
//                             fit: BoxFit.cover,
//                           )
//                         : Image.file(
//                             attachmentPreview!,
//                             fit: BoxFit.fitHeight,
//                             width: 70,
//                             height: 70,
//                           ),
//                   ))),
//         ),
//         Positioned(
//           top: 0,
//           right: 5,
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 attachmentPreview = null;
//                 galleryImageUrl = null;
//               });
//             },
//             child: const Icon(Iconsax.close_circle),
//           ),
//         ),
//       ],
//     );
//   }

//   void _addImage() async {
//     showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       enableDrag: true,
//       builder: (context) => ImageSourceSheet(
//         onImageSelected: (image) async {
//           if (image != null) {
//             Navigator.pop(context);
//             setState(() {
//               attachmentPreview = image;
//               galleryImageUrl = null;
//             });
//           }
//         },
//         onGallerySelected: (imageUrl) async {
//           setState(() {
//             galleryImageUrl = imageUrl;
//             attachmentPreview = null;
//           });
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   void _publishInteractive() async {
//     if (_postTextController.text == "") {
//       Get.snackbar(_i18n.translate("validation_warning"),
//           _i18n.translate("validation_insufficient_caharacter"),
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: APP_WARNING,
//           colorText: Colors.black);
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });
//     String? photoUrl = galleryImageUrl;
//     if (attachmentPreview != null) {
//       try {
//         photoUrl = await uploadFile(
//             file: attachmentPreview!,
//             category: UPLOAD_PATH_INTERACTIVE,
//             categoryId: createUUID());
//       } catch (err, s) {
//         await FirebaseCrashlytics.instance.recordError(err, s,
//             reason: 'Unable to upload image in interactive create',
//             fatal: false);
//       }
//     }

//     try {
//       final _interactiveApi = InteractiveBoardApi();
//       InteractiveBoard interactive = await _interactiveApi.postInteractive(
//           prompt: _postTextController.text, photoUrl: photoUrl);
//       Get.to(() => InteractivePageView(interactive: interactive));
//     } catch (err, s) {
//       Get.snackbar(
//           _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: APP_ERROR,
//           colorText: Colors.black);
//       await FirebaseCrashlytics.instance.recordError(err, s,
//           reason: 'Error publishig interactive post', fatal: true);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
// }
