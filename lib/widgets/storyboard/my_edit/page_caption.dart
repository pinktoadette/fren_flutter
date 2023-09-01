import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/add_edit_text.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/add_edit_text.dart';

class PageTextCaption extends StatefulWidget {
  /// Only one script is allowed in Caption Mode
  final Script script;

  /// Update text
  final Function(AddEditTextCharacter newcontent)? onUpdateText;

  final bool isPublished;

  const PageTextCaption(
      {super.key,
      required this.script,
      this.onUpdateText,
      this.isPublished = true});

  @override
  State<PageTextCaption> createState() => _PageTextCaptionState();
}

class _PageTextCaptionState extends State<PageTextCaption> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    String text = widget.script.text ?? "";
    return Container(
        width: size.width,
        height: 170,
        color: const Color.fromARGB(255, 20, 20, 20).withAlpha(130),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                padding: const EdgeInsets.only(
                    left: 20, top: 20, right: 0, bottom: 10),
                width: size.width - 40,
                height: 170,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style:
                            const TextStyle(color: APP_INVERSE_PRIMARY_COLOR),
                      ),
                      if (widget.isPublished == false)
                        IconButton(
                            onPressed: () {
                              _onPageEditText();
                            },
                            icon: const Icon(
                              Iconsax.edit,
                              size: 20,
                              color: APP_INVERSE_PRIMARY_COLOR,
                            ))
                    ],
                  ),
                )),
            if (text.length > 200)
              Lottie.asset('assets/lottie/down_arrow.json',
                  width: 20, height: 20, repeat: false),
          ],
        ));
  }

  void _onPageEditText() async {
    Get.to(() => AddEditTextWidget(
          script: widget.script,
          onTextComplete: (content) => widget.onUpdateText!(content),
        ));
  }
}
