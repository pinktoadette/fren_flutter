import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/chat/add_new_storyboard.dart';
import 'package:machi_app/widgets/storyboard/list_my_board.dart';
import 'package:iconsax/iconsax.dart';

// ignore: must_be_immutable
class DoubleTapChatMessage extends StatefulWidget {
  types.Message message;
  DoubleTapChatMessage({Key? key, required this.message}) : super(key: key);

  @override
  _DoubleTapChatMessageState createState() => _DoubleTapChatMessageState();
}

class _DoubleTapChatMessageState extends State<DoubleTapChatMessage> {
  late AppLocalizations _i18n;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: Text(
            _i18n.translate("storyboard"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              _i18n.translate("story_added_info"),
              style: Theme.of(context).textTheme.labelSmall,
            )),
        Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: DottedBorder(
              dashPattern: [4],
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                    height: 100,
                    width: width,
                    child: InkWell(
                      onTap: () {
                        _showBottomSheet(widget.message);
                      },
                      child: const Icon(Iconsax.add),
                    )),
              ),
            )),
        const SizedBox(
          height: 5,
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(_i18n.translate("add_to_exist_storyboard"))),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height - 345,
                child: ListMyStories(message: widget.message),
              )
            ],
          ),
        )
      ],
    );
  }

  void _showBottomSheet(types.Message message) {
    Navigator.of(context).pop();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 250,
                  child: AddNewStoryboard(
                    message: message,
                  )),
            ));
  }
}
