import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step1_dimension.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step2_style.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step3_prompt.dart';

class ImageWizardWidget extends StatefulWidget {
  final Function(String url) onComplete;
  final Function(String prompt) onAppendPrompt;
  final Function(bool isLoading) onLoading;
  final Function(String errorMessage) onError;

  const ImageWizardWidget(
      {super.key,
      required this.onComplete,
      required this.onAppendPrompt,
      required this.onLoading,
      required this.onError});

  @override
  State<ImageWizardWidget> createState() => _ImageWizardWidgetState();
}

class _ImageWizardWidgetState extends State<ImageWizardWidget> {
  String _appendPrompt = "";
  int _step = 0;
  late AppLocalizations _i18n;

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
    _i18n = AppLocalizations.of(context);
    List<Widget> pages = [
      WizardImageDimension(
        onSelectedDimension: (dimension) {
          setState(() {
            _appendPrompt += dimension;
          });
        },
      ),
      WizardImageStyle(onSelectedStyle: (onSelectedStyle) {
        setState(() {
          _appendPrompt += " $onSelectedStyle";
        });
        widget.onAppendPrompt(_appendPrompt);
      }),
      WizardPrompt(
        appendPrompt: _appendPrompt,
        onSelectedImageUrl: (imageUrl) {
          widget.onComplete(imageUrl);
        },
        onError: (errorMessage) {
          widget.onError(errorMessage);
        },
        onLoading: (isLoading) {
          widget.onLoading(isLoading);
        },
      )
    ];
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          pages[_step],
          const SizedBox(
            height: 50,
          ),
          if (_step != pages.length - 1)
            ElevatedButton.icon(
                onPressed: () {
                  if (_step == pages.length - 1) {
                    widget.onComplete(_appendPrompt);
                  } else {
                    setState(() {
                      _step += 1;
                    });
                  }
                },
                icon: const SizedBox.shrink(),
                label: Text(_i18n.translate("next_step")))
        ],
      ),
    );
  }
}
