import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/forms/category_dropdown.dart';

/// StoryInfo's edit
/// Note: Image is removed. Too complicated when displaying.
class StoryEdit extends StatefulWidget {
  const StoryEdit({Key? key, required this.onUpdateStory}) : super(key: key);
  final Function(Story story) onUpdateStory;

  @override
  State<StoryEdit> createState() => _StoryEditState();
}

class _StoryEditState extends State<StoryEdit> {
  final StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  final _titleController = TextEditingController();

  String? _selectedCategory;

  bool isLoading = false;
  late Size size;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    setState(() {
      _titleController.text = storyboardController.currentStory.title;
      _selectedCategory = storyboardController.currentStory.category;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                  icon: isLoading == true
                      ? loadingButton(size: 16, color: Colors.black)
                      : const SizedBox.shrink(),
                  onPressed: () {
                    _saveStory();
                  },
                  label: Text(_i18n.translate("SAVE")))),
          Text(_i18n.translate("creative_mix_title"),
              style: Theme.of(context).textTheme.labelMedium),
          TextFormField(
            controller: _titleController,
            maxLength: 80,
            buildCounter: (_,
                    {required currentLength, maxLength, required isFocused}) =>
                _counter(context, currentLength, maxLength),
            decoration: InputDecoration(
                hintText: _i18n.translate("creative_mix_title"),
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                floatingLabelBehavior: FloatingLabelBehavior.always),
            validator: (reason) {
              if (reason?.isEmpty ?? false) {
                return _i18n.translate("creative_mix_enter_title");
              }
              return null;
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
          const SizedBox(
            height: 20,
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
    );
  }

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$currentLength/$maxLength",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
              ],
            )
          ])),
    );
  }

  void _saveStory() async {
    setState(() {
      isLoading = true;
    });
    Story story = storyboardController.currentStory;
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

      await _storyApi.updateStory(
          story: story,
          title: _titleController.text,
          category: _selectedCategory);
      Story s = story.copyWith(
          title: _titleController.text, category: _selectedCategory);

      storyboardController.updateStory(story: s);
      widget.onUpdateStory(s);

      Get.snackbar(
          _i18n.translate("success"), _i18n.translate("update_successful"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
      Get.back();
    } catch (err, s) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot save story', fatal: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
