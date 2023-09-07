import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step1_dimension.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step2_style.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step3_prompt.dart';

/// AI image wizard that walks through in creating an ai image.
/// This wizard contains 3 steps.
class ImageWizardWidget extends StatefulWidget {
  /// disables content image
  final bool? disableContentImage;

  /// The url that user selects.
  final Function(String url) onComplete;

  /// Determines the dimension.
  final Function(String prompt) onAppendDimension;

  /// Shows loading indicator when AI image model is processing.
  final Function(bool isLoading) onLoading;

  /// Any errors thrown back.
  final Function(String errorMessage) onError;

  const ImageWizardWidget(
      {super.key,
      required this.onComplete,
      required this.onAppendDimension,
      required this.onLoading,
      required this.onError,
      this.disableContentImage = false});

  @override
  State<ImageWizardWidget> createState() => _ImageWizardWidgetState();
}

class _ImageWizardWidgetState extends State<ImageWizardWidget> {
  String _appendPrompt = "sdxl";
  String _appendDimension = "";
  int _step = 0;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    if (widget.disableContentImage == true) {
      _appendDimension = "480v";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      WizardImageDimension(
        disableContentImage: widget.disableContentImage,
        onSelectedDimension: (dimension) {
          if (!mounted) {
            return;
          }
          setState(() {
            _appendDimension = dimension;
          });
          widget.onAppendDimension(_appendDimension);
        },
      ),
      WizardImageStyle(onSelectedStyle: (onSelectedStyle) {
        if (!mounted) {
          return;
        }
        setState(() {
          _appendPrompt = onSelectedStyle;
        });
      }),
      WizardPrompt(
        appendPrompt: "$_appendPrompt $_appendDimension",
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
