import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_generative.dart';

class WizardPrompt extends StatefulWidget {
  final String appendPrompt;
  final Function(String image) onSelectedImageUrl;

  const WizardPrompt(
      {Key? key, required this.onSelectedImageUrl, required this.appendPrompt})
      : super(key: key);

  @override
  State<WizardPrompt> createState() => _WizardPromptState();
}

class _WizardPromptState extends State<WizardPrompt> {
  final List<Script> script = [];
  bool _showLoading = false;
  bool _isUploading = false;
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    ProgressDialog pr = ProgressDialog(context, isDismissible: false);

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          i18n.translate("creative_mix_ai_image_credits"),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        ImagePromptGeneratorWidget(
          isProfile: false,
          appendPrompt: widget.appendPrompt,
          onButtonClicked: (onclick) {
            pr.show(i18n.translate("processing"));

            setState(() {
              _showLoading = onclick;
            });
          },
          onImageSelected: (value) {
            setState(() {
              _selectedUrl = value;
            });
            widget.onSelectedImageUrl(value);
          },
          onImageReturned: (bool onImages) {
            setState(() {
              _showLoading = !onImages;
            });
            pr.hide();
          },
        ),
        if (_showLoading)
          TextButton.icon(
              onPressed: null,
              icon: loadingButton(size: 16, color: APP_ACCENT_COLOR),
              label: const Text("Generating images")),
        if (_selectedUrl != null && _showLoading == false)
          TextButton.icon(
              onPressed: null,
              icon: loadingButton(size: 16, color: APP_ACCENT_COLOR),
              label: const Text("Transfering Image"))
      ],
    );
  }
}
