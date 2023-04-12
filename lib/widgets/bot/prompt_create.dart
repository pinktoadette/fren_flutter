import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/widgets/image_source_sheet.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/no_data.dart';

class CreateMachiWidget extends StatefulWidget {
  const CreateMachiWidget({Key? key}) : super(key: key);

  @override
  _CreateMachiWidget createState() => _CreateMachiWidget();
}

class _CreateMachiWidget extends State<CreateMachiWidget> {
  final _botApi = BotModel();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _promptController = TextEditingController();

  List<Bot>? _listBot;

  Future<void> _fetchAllBots() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bots =
        await _botApi.getAllBotsTrend();
    List<Bot> result = [];
    for (var doc in bots) {
      result.add(Bot.fromDocument({...doc.data(), BOT_ID: doc.id}));
    }
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
    final _i18n = AppLocalizations.of(context);

    if (_listBot == null) {
      return const Frankloader();
    } else if (_listBot!.isEmpty) {
      /// No match
      return NoData(text: _i18n.translate("no_match"));
    } else {
      return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                      "Domain knowledge creation. \nConnect your Github, link your account to Hugging Face. Let others contribute to your data or monetize your domain knowledge.");
                            },
                            child: Text(
                              "Advance",
                              style: Theme.of(context).textTheme.labelSmall,
                            ))
                      ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                    _nameController.value.text.substring(0, 1)),
                              ),
                              TextFormField(
                                maxLength: 40,
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: _i18n.translate("bot_name"),
                                  hintText: _i18n.translate("bot_name_hint"),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
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
                          const SizedBox(height: 10),
                          TextFormField(
                            maxLength: 200,
                            controller: _aboutController,
                            decoration: InputDecoration(
                              labelText: _i18n.translate("about"),
                              hintText: _i18n.translate("bot_about_hint"),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            maxLines: 2,
                            validator: (bio) {
                              if (bio?.isEmpty ?? false) {
                                return _i18n.translate("required_field");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            maxLength: 1000,
                            controller: _promptController,
                            decoration: InputDecoration(
                              labelText: _i18n.translate("bot_prompt"),
                              hintText: _i18n.translate("bot_prompt_hint"),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            maxLines: 20,
                            validator: (name) {
                              // Basic validation
                              if (name?.isEmpty ?? false) {
                                return _i18n.translate("required_field");
                              }
                              return null;
                            },
                          ),
                        ]),
                    Text(
                      _i18n.translate("bot_test_warning"),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text(_i18n.translate("publish"))),
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ])));
    }
  }

  void _selectImage({required String imageUrl, required String path}) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  Navigator.of(context).pop();
                }
              },
            ));
  }
}
