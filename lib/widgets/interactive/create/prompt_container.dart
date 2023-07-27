import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/interactive_board_controller.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/screens/interactive/interactive_board_page.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/interactive/create/confirm_prompt.dart';
import 'package:machi_app/widgets/interactive/create/create_prompt.dart';
import 'package:machi_app/widgets/interactive/create/prompt_theme.dart';

/// PromptContainer wraps create prompt, and themes.
/// step 1. create prompt. Step 2 select theme.
class PromptContainer extends StatefulWidget {
  const PromptContainer({Key? key}) : super(key: key);
  @override
  _PromptContainerState createState() => _PromptContainerState();
}

class _PromptContainerState extends State<PromptContainer> {
  InteractiveBoardController _interactiveController =
      Get.find(tag: 'interactive');
  int _currentPage = 0;
  late AppLocalizations _i18n;
  final List<Widget> pages = [];
  final TextEditingController _postTextController = TextEditingController();

  bool _isLoading = false;
  String? _prompt;

  CreateNewInteractive? _newTheme;
  List<InteractiveTheme> _themes = [];

  @override
  void initState() {
    super.initState();
    _loadThemes();

    List<Widget> p = [
      Obx(() => CreatePrompt(
            prompt: _interactiveController.createInteractive.value!.prompt,
            onDataChanged: (value) {
              CreateNewInteractive newTheme =
                  _newTheme!.copyWith(prompt: value);
              _interactiveController.createInteractive(newTheme);
            },
            postTextController: _postTextController,
          )),
      Obx(() => ThemePrompt(
            themes: _themes,
            selectedTheme:
                _interactiveController.createInteractive.value?.theme,
            onThemeSelected: (theme) {
              CreateNewInteractive newTheme = _newTheme!.copyWith(theme: theme);
              _interactiveController.createInteractive(newTheme);
            },
          )),
      Obx(() => ConfirmPrompt(
            post: _interactiveController.createInteractive.value!,
            onConfirm: (value) {
              if (value == true) {
                _publishInteractive();
              }
            },
          )),
    ];

    pages.addAll(p);
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    double headerHeight = size.height * 0.1 + 50;
    double bottomSheetHeight = size.height - headerHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _i18n.translate("post_create"),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        Stack(
          children: [
            Container(
                padding: const EdgeInsets.only(bottom: 100),
                height: bottomSheetHeight,
                child: SingleChildScrollView(
                  // Add a SingleChildScrollView to enable scrolling
                  child: pages[_currentPage],
                )),
            Positioned(
                bottom: 0,
                width: size.width,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  color: Theme.of(context).colorScheme.background,
                  child: _buildBottomSheetControls(),
                ))
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSheetControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentPage > 0)
          OutlinedButton(
            onPressed: () {
              setState(() {
                _currentPage--;
              });
            },
            child: Text(_i18n.translate("previous_step")),
          ),
        ElevatedButton(
            onPressed: () {
              if (_currentPage == 0 && _prompt == "") {
                return;
              } else if (_currentPage == pages.length - 1) {
                _publishInteractive();
              } else {
                setState(() {
                  _currentPage++;
                });
              }
            },
            child: Text(
              _currentPage < pages.length - 1
                  ? _i18n.translate("next_step")
                  : _i18n.translate(
                      "publish"), // Change the label on the last step
            )),
      ],
    );
  }

  Future<void> _loadThemes() async {
    String jsonContent = await rootBundle.loadString('assets/json/theme.json');
    List<dynamic> decodedJson = jsonDecode(jsonContent);
    List<InteractiveTheme> themes = [];
    for (var item in decodedJson) {
      InteractiveTheme _theme = InteractiveTheme.fromJson(item);
      themes.add(_theme);
    }

    setState(() {
      _themes = themes;
    });

    setState(() {
      _newTheme = CreateNewInteractive(theme: _themes[0], prompt: "");
    });
  }

  void _publishInteractive() async {
    if (_prompt == "" || _prompt == null) {
      Get.snackbar(_i18n.translate("validation_warning"),
          _i18n.translate("validation_insufficient_caharacter"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_WARNING,
          colorText: Colors.black);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final _interactiveApi = InteractiveBoardApi();
      InteractiveBoard interactive =
          await _interactiveApi.postInteractive(prompt: _prompt!);
      Get.to(() => InteractivePageView(interactive: interactive));
    } catch (err, s) {
      Get.snackbar(
          _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
          colorText: Colors.black);
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error publishig interactive post', fatal: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
