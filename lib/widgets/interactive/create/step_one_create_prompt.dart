// ignore_for_file: constant_identifier_names

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';

/// step 1. create prompt. Step 2 select theme.
class CreatePrompt extends StatefulWidget {
  final Function(dynamic data) onDataChanged;

  const CreatePrompt({Key? key, required this.onDataChanged}) : super(key: key);

  @override
  _CreatePromptState createState() => _CreatePromptState();
}

class _CreatePromptState extends State<CreatePrompt> {
  final _postTextController = TextEditingController();

  late AppLocalizations _i18n;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _initialSelection(),
    );
  }

  Widget _initialSelection() {
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
                    _showHelperDetails();
                  },
                  child: const Text("ChatGPT")),
            ),
            _promptModeDisplay()
          ],
        ));
  }

  Widget _promptModeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
            child: TextFormField(
              style: const TextStyle(fontSize: 16),
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              controller: _postTextController,
              onChanged: (value) => widget.onDataChanged(value),
              decoration: InputDecoration(
                  hintText: _i18n.translate("post_interactive_hint")),
              maxLines: 10,
              maxLength: 300,
            ))
      ],
    );
  }

  _showHelperDetails() {
    String text = "";
    if (_postTextController.selection.isValid == true &&
        _postTextController.selection.textInside(_postTextController.text) !=
            "") {
      text = _postTextController.selection.textInside(_postTextController.text);
    } else {
      text = _postTextController.text;
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
                            if (_postTextController.selection.isValid == false)
                              {_postTextController.text = value}
                            else
                              {_replaceText(value)}
                          },
                      text: text)),
            )));
  }

  void _replaceText(String newText) {
    final int start = _postTextController.selection.start;
    final int end = _postTextController.selection.end;

    // Get the original text
    String originalText = _postTextController.text;

    String textBeforeSelection = originalText.substring(0, start);
    String textAfterSelection = originalText.substring(end);

    // Combine the parts with the new text
    String replacedText = textBeforeSelection + newText + textAfterSelection;

    // Update the text controller with the replaced text and the correct selection
    _postTextController.value = TextEditingValue(
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
