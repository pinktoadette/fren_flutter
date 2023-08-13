import 'dart:async';

import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/storyboard/my_edit/create_story/create_outline_text.dart';

class CreateOutlinePage extends StatefulWidget {
  const CreateOutlinePage({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateOutlinePage> createState() => _CreateOutlinePageState();
}

class _CreateOutlinePageState extends State<CreateOutlinePage> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final TextEditingController _newTextController = TextEditingController();
  late AppLocalizations _i18n;
  Story? story;
  bool _isSaving = false;
  TextUpdate? _selectedText;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    story = storyboardController.currentStory;

    /// auto save timer
    _startAutoSaveTimer();
  }

  void _startAutoSaveTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isSaving) {
        setState(() {
          _isSaving = true;
        });

        // Perform your API call or save operation here

        setState(() {
          _isSaving = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _newTextController.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _i18n.translate("creative_mix_create"),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          if (_isSaving == true)
            loadingButton(size: 16, color: APP_ACCENT_COLOR),
          if (story != null)
            TextButton(
              onPressed: () => Get.to(() => StoryPageView(
                    story: story!,
                    isPreview: true,
                  )),
              child: Text(_i18n.translate("creative_mix_preview"),
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Obx(() => ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        storyboardController.currentStory.pages?.length ?? 0,
                    itemBuilder: ((context, index) {
                      if (storyboardController.currentStory.pages?.isEmpty ??
                          true) {
                        return const SizedBox.shrink();
                      }
                      StoryPages page =
                          storyboardController.currentStory.pages![index];
                      if (page.scripts?.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Page ${index + 1}",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          ...page.scripts!.map((script) {
                            return CreateOutlineText(
                              onSelectedText: (TextUpdate selection) =>
                                  setState(() {
                                _selectedText = selection;
                              }),
                              onUpdatedScript: (update) {},
                              pageNum: index,
                              script: script,
                            );
                          }).toList(),
                        ],
                      );
                    }),
                    separatorBuilder: (BuildContext context, int index) {
                      if ((index + 1) % 3 == 0) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                              top: 10, bottom: 10),
                          child: Container(
                            height: AD_HEIGHT,
                            width: size.width,
                            color: Theme.of(context).colorScheme.background,
                            child: const InlineAdaptiveAds(),
                          ),
                        );
                      } else {
                        return const Divider();
                      }
                    },
                  )),
              Text(
                "Page ${((storyboardController.currentStory.pages?.length ?? 0) + 1).toString()}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Container(
                  constraints: const BoxConstraints(
                    minHeight: 100.0,
                  ),
                  child: TextFormField(
                    maxLines: null,
                    controller: _newTextController,
                    decoration: InputDecoration(
                        hintText: _i18n.translate("creative_mix_start_writing"),
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        floatingLabelBehavior: FloatingLabelBehavior.always),
                  )),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () {
                      Story story = storyboardController.currentStory;
                      List<StoryPages> pages;
                      Script script = Script(text: _newTextController.text);
                      if (story.pages != null) {}
                    },
                    child: Text(_i18n.translate("add"))),
              )
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: APP_INVERSE_PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => FractionallySizedBox(
                  heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
                  child: DraggableScrollableSheet(
                    snap: true,
                    initialChildSize: 1,
                    minChildSize: 0.9,
                    builder: (context, scrollController) =>
                        SingleChildScrollView(
                            controller: scrollController,
                            child: MachiHelper(
                                onTextReplace: (value) => {
                                      if (_selectedText == null)
                                        {_newTextController.text = value}
                                      else
                                        {
                                          _replaceText(value),
                                        }
                                    },
                                text: _selectedText?.selection ?? "")),
                  )));
        },
        child: const Icon(Icons.lightbulb_outlined),
      ),
    );
  }

  void _replaceText(String newText) {
    if (_selectedText != null) {
      final int start = _selectedText!.indexStart;
      final int end = _selectedText!.indexEnd;

      // Get the original text
      String originalText = _selectedText!.original.text ?? "";

      String textBeforeSelection = originalText.substring(0, start);
      String textAfterSelection = originalText.substring(end);

      // Combine the parts with the new text
      String replacedText = textBeforeSelection + newText + textAfterSelection;

      // Update the text controller with the replaced text and the correct selection
      Script updatedScript =
          _selectedText!.original.copyWith(text: replacedText);
      storyboardController.updateScript(
          script: updatedScript, pageNum: _selectedText!.pageNum);
      Get.back();

      // Get.snackbar(i18n.translate("success"), "Text is replaced",
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: APP_SUCCESS,
      //     colorText: Colors.black);
    }
  }
}
