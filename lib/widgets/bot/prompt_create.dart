import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/controller/set_room_bot.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/uploader.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/no_data.dart';
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
  final _aboutController = TextEditingController();
  final _promptController = TextEditingController();
  late ProgressDialog _pr;
  late AppLocalizations _i18n;
  File? _uploadPath;

  List<Bot> _listBot = [];

  Future<void> _fetchAllBots() async {
    List<Bot> result = await _botApi.getAllBots(5, 0, BotModelType.prompt);
    setState(() => _listBot = result);
  }

  @override
  void initState() {
    super.initState();
    _fetchAllBots();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _aboutController.dispose();
    _promptController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    _pr = ProgressDialog(context, isDismissible: false);

    if (_listBot.isEmpty) {
      return NoData(text: _i18n.translate("no_match"));
    } else {
      return Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _i18n.translate("my_machi"),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.left,
                ),
                TextButton(
                    onPressed: () {
                      infoDialog(context,
                          title: "Join the Waitlist",
                          message:
                              "Connect your Github, link your account to Replicate.");
                    },
                    child: Text(
                      "Advance",
                      style: Theme.of(context).textTheme.labelSmall,
                    ))
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
                          buildCounter: (_,
                                  {required currentLength,
                                  maxLength,
                                  required isFocused}) =>
                              _counter(context, currentLength, maxLength),
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: _i18n.translate("bot_name"),
                            hintText: _i18n.translate("bot_name_hint"),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(_nameController.text.length > 1
                                    ? _nameController.text.substring(0, 1)
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                  const SizedBox(height: 30),
                  TextFormField(
                    maxLength: 200,
                    buildCounter: (_,
                            {required currentLength,
                            maxLength,
                            required isFocused}) =>
                        _counter(context, currentLength, maxLength),
                    controller: _aboutController,
                    decoration: InputDecoration(
                        labelText: _i18n.translate("about"),
                        hintText: _i18n.translate("bot_about_hint"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary)),
                    maxLines: 2,
                    validator: (bio) {
                      if (bio?.isEmpty ?? false) {
                        return _i18n.translate("required_field");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    maxLength: 2500,
                    buildCounter: (_,
                            {required currentLength,
                            maxLength,
                            required isFocused}) =>
                        _counter(context, currentLength, maxLength),
                    controller: _promptController,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_prompt"),
                      hintText: _i18n.translate("bot_prompt_hint"),
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
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
            errorMessage != ''
                ? Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.labelSmall,
                    selectionColor: APP_ERROR,
                  )
                : const SizedBox(height: 30),
            Text(
              _i18n.translate("bot_test_warning"),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _onHandleSubmitBot(context);
                  },
                  child: Text(_i18n.translate("publish"))),
            ),
          ]));
    }
  }

  void _onHandleSubmitBot(BuildContext context) async {
    setState(() {
      errorMessage = '';
    });
    _pr.show(_i18n.translate("processing"));
    String name = _nameController.text;
    BotModelType modelType = BotModelType.prompt;
    String about = _aboutController.text;
    String prompt = _promptController.text;

    String photoUrl = await uploadFile(
        file: _uploadPath!, category: 'machi', categoryId: name);

    try {
      Bot bot = await _botApi.createBot(
          name: name,
          modelType: modelType,
          about: about,
          prompt: prompt,
          photoUrl: photoUrl);
      await _chatroomApi.tryBot();
      _clear();
      Navigator.of(context).pop();
      SetCurrentRoom().setNewBotRoom(bot);
    } catch (error) {
      Get.snackbar(
        'Error',
        _i18n.translate("an_error_occurred_while_updating_your_profile"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    } finally {
      _pr.hide();
    }
  }

  void _clear() {
    _promptController.clear();
    _nameController.clear();
    _aboutController.clear();
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
                  });
                  Navigator.of(context).pop();
                }
              },
            ));
  }
}
