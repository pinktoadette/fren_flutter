// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/screens/interactive/interactive_board_page.dart';
import 'package:machi_app/widgets/interactive/create/step_one_create_prompt.dart';
import 'package:machi_app/widgets/interactive/create/step_two_theme_prompt.dart';

enum Mode { INTERACTIVE, BOARD }

/// PromptContainer wraps create prompt, and themes.
/// step 1. create prompt. Step 2 select theme.
class PromptContainer extends StatefulWidget {
  const PromptContainer({Key? key}) : super(key: key);
  @override
  _PromptContainerState createState() => _PromptContainerState();
}

class _PromptContainerState extends State<PromptContainer> {
  int _currentPage = 0;
  late AppLocalizations _i18n;
  final List<Widget> pages = [];

  bool _isLoading = false;
  String? _prompt;
  String? _galleryImageUrl;
  File? _attachmentPreview;

  @override
  void initState() {
    super.initState();

    pages.add(CreatePrompt(onDataChanged: (value) {
      setState(() {
        _prompt = value;
      });
    }));
    pages.add(const ThemePrompt());
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    double headerHeight = 100;
    double bottomSheetHeight = size.height - headerHeight;
    double promptHeight = bottomSheetHeight * 0.8;

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
                height: promptHeight,
                child: SingleChildScrollView(
                  // Add a SingleChildScrollView to enable scrolling
                  child: pages[_currentPage],
                )),
            Positioned(
              bottom: 0,
              width: size.width,
              child: _buildBottomSheetControls(),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSheetControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentPage >
            0) // Show the "Previous" button only if not on the first prompt
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
            if (_currentPage < pages.length - 1) {
              setState(() {
                _currentPage++;
              });
            } else {
              // If it's the last page, perform the final action (e.g., publish the interactive)
              _publishInteractive();
            }
          },
          child: Text(
            _currentPage < pages.length - 1
                ? _i18n.translate("next_step")
                : _i18n
                    .translate("publish"), // Change the label on the last step
          ),
        ),
      ],
    );
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
    String? photoUrl = _galleryImageUrl;
    if (_attachmentPreview != null) {
      try {
        photoUrl = await uploadFile(
            file: _attachmentPreview!,
            category: UPLOAD_PATH_INTERACTIVE,
            categoryId: createUUID());
      } catch (err, s) {
        await FirebaseCrashlytics.instance.recordError(err, s,
            reason: 'Unable to upload image in interactive create',
            fatal: false);
      }
    }

    try {
      final _interactiveApi = InteractiveBoardApi();
      InteractiveBoard interactive = await _interactiveApi.postInteractive(
          prompt: _prompt!, photoUrl: photoUrl);
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
