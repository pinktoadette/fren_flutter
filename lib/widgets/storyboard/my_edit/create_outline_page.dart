import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';

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
  final List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _newTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            _i18n.translate("storybits_create"),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: [],
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
                            ...page.scripts!.asMap().entries.map((entry) {
                              final textFieldIndex = entry.key;
                              final script = entry.value;

                              textControllers.add(TextEditingController(
                                  text: script.text?.trim()));

                              return Container(
                                constraints: const BoxConstraints(
                                  minHeight: 100.0,
                                ),
                                child: TextField(
                                  key: ValueKey(
                                      '${index}_$textFieldIndex'), // Unique key
                                  controller: textControllers[textFieldIndex],
                                  onChanged: (value) {
                                    // Handle text changes using: textControllers[textFieldIndex].text
                                  },
                                  maxLines: null, // Allow text to wrap
                                  decoration: InputDecoration(
                                    hintText: 'Enter your text',
                                    // Add other decoration properties as needed
                                  ),
                                  // Add other TextField properties as needed
                                ),
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
                TextFormField(
                  controller: _newTextController,
                  decoration: InputDecoration(
                      hintText: _i18n.translate("story_collection_script"),
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () {}, child: Text(_i18n.translate("add"))),
                )
              ],
            )));
  }
}
