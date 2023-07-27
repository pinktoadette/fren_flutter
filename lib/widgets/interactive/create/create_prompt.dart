// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';

/// step 1. create prompt. Step 2 select theme.
class CreatePrompt extends StatelessWidget {
  final String? prompt;
  final Function(dynamic data) onDataChanged;
  final TextEditingController postTextController;

  const CreatePrompt({
    Key? key,
    required this.onDataChanged,
    this.prompt,
    required this.postTextController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _initialSelection(context),
    );
  }

  Widget _initialSelection(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  _i18n.translate("post_interactive_info"),
                  style: Theme.of(context).textTheme.labelSmall,
                )),
            Container(
              margin: const EdgeInsets.only(left: 20, top: 10),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                      width: 1,
                      color: Colors.grey,
                      strokeAlign: BorderSide.strokeAlignCenter)),
              child: TextButton(
                  onPressed: () {
                    _showHelperDetails(context);
                  },
                  child: const Text("ChatGPT")),
            ),
            _promptModeDisplay(context)
          ],
        ));
  }

  Widget _promptModeDisplay(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
            child: TextFormField(
              style: const TextStyle(fontSize: 16),
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              controller: postTextController,
              onChanged: (value) {
                onDataChanged(value);
              },
              decoration: InputDecoration(
                  hintText: _i18n.translate("post_interactive_hint")),
              maxLines: 10,
              maxLength: 300,
            ))
      ],
    );
  }

  _showHelperDetails(BuildContext context) {
    String text = "";
    if (postTextController.selection.isValid == true &&
        postTextController.selection.textInside(postTextController.text) !=
            "") {
      text = postTextController.selection.textInside(postTextController.text);
    } else {
      text = postTextController.text;
    }

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.55,
            child: DraggableScrollableSheet(
              snap: true,
              initialChildSize: 1,
              minChildSize: 0.9,
              builder: (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: MachiHelper(
                      onTextReplace: (value) => {
                            if (postTextController.selection.isValid == false)
                              {postTextController.text = value}
                            else
                              {_replaceText(value, context)}
                          },
                      text: text)),
            )));
  }

  void _replaceText(String newText, BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    final int start = postTextController.selection.start;
    final int end = postTextController.selection.end;

    // Get the original text
    String originalText = postTextController.text;

    String textBeforeSelection = originalText.substring(0, start);
    String textAfterSelection = originalText.substring(end);

    // Combine the parts with the new text
    String replacedText = textBeforeSelection + newText + textAfterSelection;

    // Update the text controller with the replaced text and the correct selection
    postTextController.value = TextEditingValue(
      text: replacedText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + newText.length,
      ),
    );

    Get.snackbar(_i18n.translate("success"), "Text is replaced",
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_SUCCESS,
        colorText: Colors.black);
  }
}
