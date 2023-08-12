import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_generative.dart';
import 'package:machi_app/widgets/walkthru/walkthru.dart';

class ImageGenerator extends StatefulWidget {
  final Function(String imageUrl) onSelection;
  const ImageGenerator({Key? key, required this.onSelection}) : super(key: key);

  @override
  State<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  late AppLocalizations _i18n;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLoading = false;
  bool _walkthruCompleted = false;

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

    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Container(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Semantics(
                        label: "${_i18n.translate("hello")} ",
                        child: Text(
                          "Let's Draw",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Semantics(
                        label: "${_i18n.translate("hello")} ",
                        child: Text(
                          "<Text of story> ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Offstage(
                        offstage: !(!_walkthruCompleted && !_showLoading) &&
                            !(_walkthruCompleted && !_showLoading),
                        child: ImagePromptGeneratorWidget(
                          isProfile: false,
                          onButtonClicked: (onclick) {
                            setState(() {
                              _showLoading = onclick;
                            });
                          },
                          onImageSelected: (value) {
                            _saveSelectedPhoto(value);
                          },
                          onImageReturned: (bool onImages) {
                            setState(() {
                              _showLoading = !onImages;
                            });
                          },
                        ),
                      ),
                      Offstage(
                        offstage: !_showLoading,
                        child: WalkThruSteps(onCarouselCompletion: () {
                          _walkthruCompleted = true;
                        }),
                      ),
                      if (_showLoading)
                        TextButton.icon(
                            onPressed: null,
                            icon: loadingButton(
                                size: 16, color: APP_ACCENT_COLOR),
                            label: const Text("Generating images"))
                    ],
                  ),
                ))));
  }

  void _saveSelectedPhoto(String photoUrl) async {}
}
