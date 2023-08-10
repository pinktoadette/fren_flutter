import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:get/get.dart';

class CreateMachiWidget extends StatefulWidget {
  const CreateMachiWidget({Key? key}) : super(key: key);

  @override
  _CreateMachiWidget createState() => _CreateMachiWidget();
}

class _CreateMachiWidget extends State<CreateMachiWidget> {
  final _botApi = BotApi();
  final _chatroomApi = ChatroomMachiApi();
  String errorMessage = '';
  BotController botController = Get.find(tag: 'bot');

  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  // final bool _isPrivate = false;

  late ProgressDialog _pr;
  late AppLocalizations _i18n;
  File? _uploadPath;
  String? photoUrl;
  final _appHelper = AppHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _promptController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    _pr = ProgressDialog(context, isDismissible: false);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _i18n.translate("my_machi"),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.left,
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.7,
                      height: 80,
                      child: TextFormField(
                        maxLength: 40,
                        style: Theme.of(context).textTheme.bodyMedium,
                        buildCounter: (_,
                                {required currentLength,
                                maxLength,
                                required isFocused}) =>
                            _counter(context, currentLength, maxLength),
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: _i18n.translate("bot_name_hint"),
                        ),
                        validator: (name) {
                          // Basic validation
                          if (name?.isEmpty ?? false) {
                            return _i18n.translate("required_field");
                          }
                          if (name?.isNotEmpty == true && name!.length < 2) {
                            return _i18n.translate("required_2_char");
                          }
                          return null;
                        },
                      ),
                    ),
                    GestureDetector(
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 40,
                              foregroundImage: _uploadPath != null
                                  ? FileImage(_uploadPath!)
                                  : null,
                              backgroundImage: photoUrl != null
                                  ? imageCacheWrapper(photoUrl!)
                                  : null,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(_nameController.text.length > 1
                                  ? photoUrl == null
                                      ? _nameController.text.substring(0, 1)
                                      : ""
                                  : "MA"),
                            ),

                            /// Edit icon
                            Positioned(
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                child: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 12,
                                ),
                              ),
                              right: 0,
                              bottom: 0,
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        /// Update profile image
                        _selectImage(path: 'machi');
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLength: 500,
                  buildCounter: (_,
                          {required currentLength,
                          maxLength,
                          required isFocused}) =>
                      _counter(context, currentLength, maxLength),
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText: _i18n.translate("bot_prompt_hint"),
                  ),
                  maxLines: 10,
                  validator: (name) {
                    // Basic validation
                    if (name?.isEmpty ?? false) {
                      return _i18n.translate("required_field");
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(_i18n.translate("bot_is_private")),
          //     Switch(
          //       activeColor: Theme.of(context).colorScheme.secondary,
          //       value: _isPrivate,
          //       onChanged: (newValue) {
          //         setState(() {
          //           _isPrivate = newValue;
          //         });
          //       },
          //     ),
          //   ],
          // ),
          errorMessage != ''
              ? Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.labelSmall,
                  selectionColor: APP_ERROR,
                )
              : const SizedBox(height: 50),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  _onHandleSubmitBot(context);
                },
                child: Text(_i18n.translate("publish"))),
          ),
          const SizedBox(
            height: 80,
          ),
          GestureDetector(
            child: Text(
              _i18n.translate("bot_test_warning"),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            onTap: () {
              // Open terms of service page in browser
              _appHelper.openTermsPage();
            },
          ),
        ]));
  }

  void _onHandleSubmitBot(BuildContext context) async {
    setState(() {
      errorMessage = '';
    });

    if (_nameController.text.toLowerCase() == 'frankie') {
      Get.snackbar(_i18n.translate("validation_warning"), "This name is taken.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_WARNING,
          colorText: Colors.black);
      return;
    }

    if (_promptController.text.length < 50 || _nameController.text.length < 3) {
      Get.snackbar(_i18n.translate("validation_warning"),
          _i18n.translate("validation_insufficient_caharacter"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_WARNING,
          colorText: Colors.black);
      return;
    }

    _pr.show(_i18n.translate("processing"));
    String name = _nameController.text;
    BotModelType modelType = BotModelType.prompt;
    String prompt = _promptController.text;
    String botImgUrl = photoUrl ?? "";
    if (_uploadPath != null) {
      botImgUrl = await uploadFile(
          file: _uploadPath!,
          category: UPLOAD_PATH_BOT_IMAGE,
          categoryId: createUUID());
    }
    if (photoUrl != "") {
      botImgUrl = await copyFileToDifferentFolder(
          sourceUrl: photoUrl!, destinationCategory: 'machi/');
    }

    try {
      Bot bot = await _botApi.createBot(
          name: name,
          modelType: modelType,
          prompt: prompt,
          photoUrl: botImgUrl);
      await _chatroomApi.createNewRoom();
      _clear();
      SetCurrentRoom().setNewBotRoom(bot, true);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot create a new prompt bot', fatal: true);
    } finally {
      _pr.hide();
    }
  }

  void _clear() {
    _promptController.clear();
    _nameController.clear();
    setState(() {
      _uploadPath = null;
      photoUrl = null;
    });
  }

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Text(
            currentLength.toString() + "/" + maxLength.toString(),
            style: Theme.of(context).textTheme.labelSmall,
          )),
    );
  }

  void _selectImage({required String path}) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  setState(() {
                    _uploadPath = image;
                    photoUrl = null;
                  });
                  Navigator.of(context).pop();
                }
              },
              onGallerySelected: (imageUrl) async {
                setState(() {
                  photoUrl = imageUrl;
                  _uploadPath = null;
                });
                Navigator.of(context).pop();
              },
            ));
  }
}
