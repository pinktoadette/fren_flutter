import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step1_dimension.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step2_style.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step3_prompt.dart';

class ImageWizardWidget extends StatefulWidget {
  final Function(String prompt) onComplete;

  const ImageWizardWidget({super.key, required this.onComplete});

  @override
  State<ImageWizardWidget> createState() => _ImageWizardWidgetState();
}

class _ImageWizardWidgetState extends State<ImageWizardWidget> {
  String _appendPrompt = "";
  List<Widget> pages = [];
  int _step = 0;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    _getPages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getPages() {
    if (!mounted) {
      return;
    }
    pages = [
      WizardImageDimension(
        onSelectedDimension: (dimension) {
          setState(() {
            _appendPrompt += dimension;
          });
        },
      ),
      WizardImageStyle(onSelectedStyle: (onSelectedStyle) {
        _appendPrompt += onSelectedStyle;
      }),
      WizardPrompt(
        appendPrompt: _appendPrompt,
        onSelectedImageUrl: (imageUrl) {
          /// upload image
          widget.onComplete(imageUrl);
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

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
