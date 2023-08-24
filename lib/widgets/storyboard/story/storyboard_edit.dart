import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/forms/category_dropdown.dart';

///@todo need to combine with story_edit.dart
/// Edit and delete storyboard, including title and images
/// Swipe to delete individual stories
/// Note: Image is removed. Too complicated when displaying.
class StoryboardEdit extends StatefulWidget {
  const StoryboardEdit({Key? key}) : super(key: key);
  @override
  State<StoryboardEdit> createState() => _StoryboardEditState();
}

class _StoryboardEditState extends State<StoryboardEdit> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Storyboard storyboard;
  final _storyboardApi = StoryboardApi();
  String? _selectedCategory;
  final _titleController = TextEditingController();
  final _aboutController = TextEditingController();

  bool isLoading = false;
  late AppLocalizations _i18n;
  late Size size;
  late TextStyle? styleLabel;
  late TextStyle? styleBody;

  @override
  void initState() {
    super.initState();
    setState(() {
      storyboard = storyboardController.currentStoryboard;
      _titleController.text = storyboard.title;
      _selectedCategory = storyboard.category;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _aboutController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
    styleLabel = Theme.of(context).textTheme.labelMedium;
    styleBody = Theme.of(context).textTheme.bodyMedium;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      label: Text(_i18n.translate("SAVE")),
                      icon: isLoading == true
                          ? loadingButton(size: 16, color: Colors.black)
                          : const SizedBox.shrink(),
                      onPressed: () {
                        _saveStoryboard();
                      },
                    )),
                Text(_i18n.translate("creative_mix_title"), style: styleLabel),
                TextFormField(
                  style: styleBody,
                  controller: _titleController,
                  maxLength: 80,
                  decoration: InputDecoration(
                      hintText: _i18n.translate("creative_mix_title"),
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  validator: (reason) {
                    if (reason?.isEmpty ?? false) {
                      return _i18n.translate("creative_mix_enter_title");
                    }
                    return null;
                  },
                ),
                CategoryDropdownWidget(
                  notifyParent: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  selectedCategory: _selectedCategory,
                ),
              ],
            ),
          ),
        ));
  }

  void _saveStoryboard() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (_titleController.text.isEmpty) {
        Get.snackbar(
          _i18n.translate("error"),
          _i18n.translate("validation_1_character"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
        );
        return;
      }

      await _storyboardApi.updateStoryboard(
          storyboardId: storyboard.storyboardId,
          title: _titleController.text,
          category: _selectedCategory ?? "General");
      Get.snackbar(
          _i18n.translate("success"), _i18n.translate("update_successful"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot save storyboard', fatal: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
