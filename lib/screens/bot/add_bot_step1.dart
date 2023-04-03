import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/bot_model.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/bot/add_bot_step2.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step1CreateBot extends StatefulWidget {
  const Step1CreateBot({Key? key}) : super(key: key);

  @override
  _Step1ContainerState createState() => _Step1ContainerState();
}

class _Step1ContainerState extends State<Step1CreateBot> {
  final BotController botController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _about = TextEditingController();
  String? _selectedDomain;
  final _subdomain = TextEditingController();
  final _prompt = TextEditingController();
  final _price = TextEditingController();
  late List<String> _domainList = ["1"];
  late AppLocalizations _i18n;
  bool _onHuggingFace = false;

  /// static job list
  Future<void> _loadDomain() async {
    String data = await rootBundle.loadString("assets/json/domains.json");
    List<String> list = List.from(jsonDecode(data) as List<dynamic>);

    setState(() {
      _domainList = list;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDomain();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Initialization
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            debugPrint("Bot return to default");
            botController.fetchCurrentBot(DEFAULT_BOT_ID);
            Future(() {
              Navigator.of(context).pop();
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_i18n.translate('create_bot'),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.left),
            ),
            const SizedBox(height: 20),

            /// Form
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  /// bot name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_name"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return _i18n.translate("required_field");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  /// bot domain
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_domain"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    items: _domainList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (domain) {
                      setState(() {
                        _selectedDomain = domain;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return _i18n.translate("required_field");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  /// bot specialty
                  TextFormField(
                    controller: _subdomain,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_subdomain"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return _i18n.translate("required_field");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  /// bot repo
                  TextFormField(
                    controller: _prompt,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_prompt"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return _i18n.translate("required_field");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  /// bot price
                  TextFormField(
                    controller: _price,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("bot_pricing"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'(^\d*\.?\d{0,2})')),
                    ],
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return _i18n.translate("required_field");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  /// Bio field
                  TextFormField(
                    controller: _about,
                    decoration: InputDecoration(
                      labelText: _i18n.translate("about"),
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
                  const SizedBox(height: 20),

                  /// bot embedding on hugging face
                  CheckboxListTile(
                    title: const Text(
                      'Embedding is on hugging face',
                      style: TextStyle(color: Colors.grey),
                    ),
                    value: _onHuggingFace,
                    onChanged: (value) {
                      setState(() => _onHuggingFace = !_onHuggingFace);
                    },
                  ),
                  const SizedBox(height: 20),

                  /// Sign Up button
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: Text(_i18n.translate("next_step"),
                          style: const TextStyle(fontSize: 18)),
                      onPressed: () {
                        _createBot();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle Create account
  void _createBot() async {
    if (!_formKey.currentState!.validate()) {
      showScaffoldMessage(
          context: context,
          message: _i18n.translate("required_field"),
          bgcolor: Colors.pinkAccent);
    } else if (!_onHuggingFace) {
      showScaffoldMessage(
          context: context,
          message: "Embedding must be on hugging face",
          bgcolor: Colors.pinkAccent);
    } else {
      _formKey.currentState!.save();
      BotModel().createBot(
        ownerId: UserModel().user.userId,
        name: _nameController.value.text.trim(),
        domain: _selectedDomain,
        subdomain: _subdomain.value.text.trim(),
        prompt: _prompt.value.text.trim(),
        temperature: 0.5,
        price: _price.value.text.trim(),
        about: _about.value.text.trim(),
        onSuccess: (botId) async {
          debugPrint("Bot made");
          botController.fetchCurrentBot(botId);
          Future(() {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Step2CreateBot()));
          });
        },
        onError: (error) {
          // Debug error
          debugPrint(error);
          // Show error message
          showScaffoldMessage(
              context: context,
              message: _i18n.translate("an_error_has_occurred"),
              bgcolor: Colors.pinkAccent);
        },
      );
    }
  }
}
