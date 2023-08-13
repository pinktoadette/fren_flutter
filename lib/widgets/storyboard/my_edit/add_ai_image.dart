import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/generative_image/image_dimension.dart';
import 'package:machi_app/widgets/image/image_generative.dart';

class ImageGenerator extends StatefulWidget {
  final String? text;
  final Story? story;
  final Function(String imageUrl) onSelection;
  const ImageGenerator(
      {Key? key, required this.onSelection, this.story, this.text})
      : super(key: key);

  @override
  State<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  late AppLocalizations _i18n;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLoading = false;
  int _step = 1;
  String _selectedDimension = "";

  @override
  void initState() {
    super.initState();
    _createStoryPreview();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createStoryPreview() {}

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Container(
                padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        _i18n.translate(
                            "creative_mix_image_generator_instruction"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Semantics(
                        label: _i18n
                            .translate("creative_mix_image_generator_describe"),
                        child: Text(
                          _i18n.translate(
                              "creative_mix_image_generator_describe"),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const Divider(height: 5, thickness: 1),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        _i18n.translate("creative_mix_ai_image_credits"),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (widget.text != null)
                        Semantics(
                          label: widget.text,
                          child: Text(
                            "Creating image for: ${widget.text}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      if (_step == 1)
                        ImageDimension(onSelectedDimention: (dimension) {
                          setState(() {
                            _step += 1;
                          });
                        })
                      else
                        Offstage(
                          offstage: _showLoading,
                          child: ImagePromptGeneratorWidget(
                            isProfile: false,
                            dimension: _selectedDimension,
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
                          child: loadingButton(size: 20)),
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

  void _saveSelectedPhoto(String photoUrl) async {
    print(photoUrl);
  }
}
