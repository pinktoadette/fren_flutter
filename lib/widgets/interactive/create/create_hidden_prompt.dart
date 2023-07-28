// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';

// ignore: must_be_immutable
/// step 1. create prompt. Step 2 select theme.
class CreateHiddenPrompt extends StatelessWidget {
  final String? hiddenPrompt;
  final Function(dynamic data) onDataChanged;
  TextEditingController? hiddenTextController;

  CreateHiddenPrompt(
      {Key? key,
      this.hiddenPrompt,
      required this.onDataChanged,
      this.hiddenTextController})
      : super(key: key);

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
                padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                child: TextFormField(
                  style: const TextStyle(fontSize: 16),
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  controller: hiddenTextController,
                  onChanged: (value) {
                    onDataChanged(value);
                  },
                  decoration: InputDecoration(
                      hintText:
                          _i18n.translate("post_interactive_hidden_hint")),
                  maxLines: 10,
                  maxLength: 300,
                ))
          ],
        ));
  }
}
