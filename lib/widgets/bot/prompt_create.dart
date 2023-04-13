import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/dialogs/common_dialogs.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/widgets/loader.dart';
import 'package:fren_app/widgets/no_data.dart';

class CreateMachiWidget extends StatefulWidget {
  const CreateMachiWidget({Key? key}) : super(key: key);

  @override
  _CreateMachiWidget createState() => _CreateMachiWidget();
}

class _CreateMachiWidget extends State<CreateMachiWidget> {
  final _botApi = BotApi();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _promptController = TextEditingController();

  List<Bot> _listBot = [];

  Future<void> _fetchAllBots() async {
    List<Bot> result = await _botApi.getAllBots(5, 0);
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
    double width = MediaQuery.of(context).size.width;

    if (_listBot == null) {
      return const Frankloader();
    } else if (_listBot.isEmpty) {
      /// No match
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
                              "Domain knowledge creation. \nConnect your Github, link your account to Hugging Face. Let others contribute to your data or monetize your domain knowledge.");
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
                        width: width * 0.6,
                        height: 80,
                        child: TextFormField(
                          maxLength: 40,
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
                      SizedBox(
                        width: width * 0.25,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(_nameController.text.length > 1
                              ? _nameController.text.substring(0, 1)
                              : "MA"),
                        ),
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
                      floatingLabelBehavior: FloatingLabelBehavior.always,
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
                    maxLength: 200,
                    controller: _promptController,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_prompt"),
                      hintText: _i18n.translate("bot_prompt_hint"),
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
            Text(
              _i18n.translate("bot_test_warning"),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    print(_nameController.text);
                  },
                  child: Text(_i18n.translate("publish"))),
            ),
          ]));
    }
  }
}
