import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
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
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';

class ImageGenerator extends StatefulWidget {
  final Story? story;
  final Function(AddEditTextCharacter imageUrl) onSelection;
  final Function(String errorMessage)? onError;

  const ImageGenerator(
      {Key? key, required this.onSelection, this.story, this.onError})
      : super(key: key);

  @override
  State<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _prompt = "";
  bool _isLoading = false;
  Timer? _timer;
  late ProgressDialog _pr;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 20,
          title: Text(
            _i18n.translate("creative_mix_image_create"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: const [SubscribeTokenCounter()],
        ),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: _i18n
                            .translate("creative_mix_image_generator_describe"),
                        child: Text(
                          _i18n.translate(
                              "creative_mix_image_generator_describe"),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ImageWizardWidget(
                          onComplete: (photoUrl) {
                            _saveSelectedPhoto(photoUrl);
                          },
                          onLoading: (isLoading) {
                            _loadProgress(isLoading);
                          },
                          onError: (errorMessage) {
                            if (widget.onError != null) {
                              widget.onError!(errorMessage);
                            }
                            _pr.hide();
                          },
                          onAppendPrompt: (prompt) => setState(() {
                                _prompt += prompt;
                              }))
                    ],
                  ),
                ))));
  }

  void _loadProgress(bool isLoading) {
    if (isLoading) {
      setState(() {
        _isLoading = true;
      });

      _timer = Timer(const Duration(seconds: 120), () {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
          AlertDialog(
            title: Text(
              _i18n.translate("error"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            content: Text(_i18n.translate("creative_mix_turn_machine_on")),
            actions: <Widget>[
              OutlinedButton(
                  onPressed: () => {
                        Navigator.of(context).pop(false),
                      },
                  child: Text(_i18n.translate("OK"))),
              const SizedBox(
                width: 50,
              ),
            ],
          );
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _timer?.cancel();
    }
  }

  void _saveSelectedPhoto(String photoUrl) async {
    _pr.show(_i18n.translate("uploading_image"));
    try {
      String newUrl = await uploadUrl(
          url: photoUrl,
          category: UPLOAD_PATH_SCRIPT_IMAGE,
          categoryId: createUUID());
      AddEditTextCharacter newItem = AddEditTextCharacter(
          galleryUrl: newUrl,
          isBackground: _prompt.contains(Dimension.vertical.value),
          characterId: UserModel().user.userId,
          characterName: UserModel().user.username);

      widget.onSelection(newItem);
      Get.back();
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack,
          reason: 'upload new ai image to bucket', fatal: false);
    } finally {
      _pr.hide();
    }
  }
}
