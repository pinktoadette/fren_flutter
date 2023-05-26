import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class PostCommentWidget extends StatefulWidget {
  final Story story;
  const PostCommentWidget({Key? key, required this.story}) : super(key: key);

  @override
  _PostCommentWidgetState createState() => _PostCommentWidgetState();
}

class _PostCommentWidgetState extends State<PostCommentWidget> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);

    return Container(
        child: Row(children: [
      TextFormField(
        controller: _commentController,
        maxLines: 1,
        maxLength: 250,
        validator: (value) {
          if ((value == null) || (value == "")) {
            return _i18n.translate("validation_1_character");
          }
        },
      )
    ]));
  }
}
