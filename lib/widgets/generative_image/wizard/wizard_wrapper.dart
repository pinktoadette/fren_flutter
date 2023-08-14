import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step1_dimension.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step2_style.dart';

class ImageWizardWidget extends StatefulWidget {
  final Function(int) onComplete;

  const ImageWizardWidget({super.key, required this.onComplete});

  @override
  State<ImageWizardWidget> createState() => _ImageWizardWidgetState();
}

class _ImageWizardWidgetState extends State<ImageWizardWidget> {
  List<Widget> pages = [
    WizardImageDimension(
      onSelectedDimension: (dimension) {},
    ),
    WizardImageStyle(onSelectedStyle: (onSelectedStyle) {})
  ];
  int _step = 0;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          pages[_step],
          const SizedBox(
            height: 50,
          ),
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _step += 1;
                });
              },
              icon: const SizedBox.shrink(),
              label: Text(i18n.translate("next_step")))
        ],
      ),
    );
  }
}
