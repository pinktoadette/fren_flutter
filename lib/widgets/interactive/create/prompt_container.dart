import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/interactive_board_controller.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/load_theme.dart';
import 'package:machi_app/screens/interactive/interactive_board_page.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/interactive/create/confirm_prompt.dart';
import 'package:machi_app/widgets/interactive/create/create_hidden_prompt.dart';
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
  final InteractiveBoardController _interactiveController =
      Get.find(tag: 'interactive');
  int _currentPage = 0;
  late AppLocalizations _i18n;
  final List<Widget> pages = [];
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _hiddenTextController = TextEditingController();

  bool _isLoading = false;
  String? _prompt;
  String? _hiddenPrompt;

  CreateNewInteractive? _newTheme;
  List<InteractiveTheme> _themes = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _loadThemes();
    List<Widget> p = [
      CreatePrompt(
        hint: _i18n.translate("post_interactive_hint"),
        prompt: _interactiveController.createInteractive.value!.prompt,
        onDataChanged: (value) {
          setState(() {
            _prompt = value;
          });
        },
        postTextController: _postTextController,
      ),

      /// hidden prompt
      CreatePrompt(
        hint: _i18n.translate("post_interactive_hidden_hint"),
        prompt: _interactiveController.createInteractive.value!.hiddenPrompt,
        onDataChanged: (value) {
          setState(() {
            _hiddenPrompt = value;
          });
          _newTheme =
              _newTheme!.copyWith(prompt: _prompt, hiddenPrompt: _hiddenPrompt);
          _interactiveController.createInteractive(_newTheme);
        },
        postTextController: _hiddenTextController,
      ),
      Obx(() => ThemePrompt(
            themes: _themes,
            selectedTheme:
                _interactiveController.createInteractive.value?.theme,
            onThemeSelected: (theme) {
              _newTheme = _newTheme!.copyWith(theme: theme, prompt: _prompt);
              _interactiveController.createInteractive(_newTheme);
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
    _hiddenTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    double headerHeight = size.height * 0.1 + 50;
    double bottomSheetHeight = size.height - headerHeight;
    if (pages.isEmpty) {
      return const SizedBox.shrink();
    }

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
        ElevatedButton.icon(
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
            icon:
                _isLoading ? loadingButton(size: 16) : const SizedBox.shrink(),
            label: Text(
              _currentPage < pages.length - 1
                  ? _i18n.translate("next_step")
                  : _i18n.translate(
                      "publish"), // Change the label on the last step
            )),
      ],
    );
  }

  Future<void> _loadThemes() async {
    List<InteractiveTheme> themes = await loadThemes();

    setState(() {
      _themes = themes;
      _newTheme =
          CreateNewInteractive(theme: _themes[0], prompt: "", hiddenPrompt: "");
    });
    _interactiveController.createInteractive(_newTheme);
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
          await _interactiveApi.postInteractive(prompt: _newTheme!);
      Get.to(() => InteractivePageView(interactive: interactive));
      Navigator.of(context).pop();
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
