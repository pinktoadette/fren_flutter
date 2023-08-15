import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/add_edit_text.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_step1_dimension.dart';
import 'package:machi_app/widgets/generative_image/wizard/wizard_wrapper.dart';

class ImageGenerator extends StatefulWidget {
  final String? text;
  final Story? story;
  final Function(AddEditTextCharacter imageUrl) onSelection;
  const ImageGenerator(
      {Key? key, required this.onSelection, this.story, this.text})
      : super(key: key);

  @override
  State<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  late AppLocalizations _i18n;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late ProgressDialog _pr;
  String _prompt = "";

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
    _pr = ProgressDialog(context, isDismissible: false);

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
                      if (widget.text != null)
                        Semantics(
                          label: widget.text,
                          child: Text(
                            "Creating image for: ${widget.text}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ImageWizardWidget(
                          onComplete: (photoUrl) {
                            _saveSelectedPhoto(photoUrl);
                          },
                          onLoading: (isLoading) {
                            _loadProgress(isLoading);
                          },
                          onAppendPrompt: (prompt) => setState(() {
                                _prompt = prompt;
                              }))
                    ],
                  ),
                ))));
  }

  void _loadProgress(bool isLoading) {
    if (isLoading == true) {
      _pr.show(_i18n.translate("processing"));
    } else {
      _pr.hide();
    }
  }

  void _saveSelectedPhoto(String photoUrl) async {
    _pr.show(_i18n.translate("processing"));
    try {
      String newUrl = await uploadUrl(
          url: photoUrl,
          category: UPLOAD_PATH_SCRIPT_IMAGE,
          categoryId: createUUID());
      AddEditTextCharacter newItem = AddEditTextCharacter(
          galleryUrl: newUrl,
          isBackground: _prompt.contains(Dimension.vertical.name),
          characterId: UserModel().user.userId,
          characterName: UserModel().user.username);

      widget.onSelection(newItem);
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack,
          reason: 'upload new ai image to bucket', fatal: false);
    } finally {
      _pr.hide();
    }
  }
}
