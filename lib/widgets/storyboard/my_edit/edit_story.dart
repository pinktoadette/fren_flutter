import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_reorder.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Need to call pages since storyboard
/// did not query this in order to increase speed
class EditPage extends StatefulWidget {
  final Story story;
  const EditPage({Key? key, required this.story}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final controller = PageController(viewportFraction: 1, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  var pages = [];

  get onUpdate => null;

  @override
  void initState() {
    _setupPages();
    super.initState();
  }

  void _setupPages() {
    pages = _getPages();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (pages.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              _i18n.translate("storybits"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit " + _i18n.translate("storybits"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            // OutlinedButton(
            //   child: Text(_i18n.translate("SAVE")),
            //   onPressed: () {
            //     FocusScope.of(context).requestFocus(FocusNode());
            //   },
            // )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                    height: height - 100,
                    width: width,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: pages.length,
                      itemBuilder: (_, index) {
                        return pages[index];
                      },
                    )),
                Positioned.fill(
                  bottom: 50,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: widget.story.pages!.length,
                      effect: const ExpandingDotsEffect(
                          dotHeight: 14,
                          dotWidth: 14,
                          // type: WormType.thinUnderground,
                          activeDotColor: APP_ACCENT_COLOR),
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }

  List _getPages() {
    /// Separate out the reorder to have its own state
    return widget.story.pages!.map((pages) {
      var scripts = pages.scripts ?? [];
      return EditPageReorder(
          scriptList: scripts,
          onUpdate: (data) {
            _updateSequence(data);
          });
    }).toList();
  }

  void _updateSequence(var data) {
    debugPrint(data);
  }
}
