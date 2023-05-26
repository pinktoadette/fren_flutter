import 'package:iconsax/iconsax.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class PostCommentWidget extends StatefulWidget {
  const PostCommentWidget({Key? key}) : super(key: key);

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
    double width = MediaQuery.of(context).size.width;
    return Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        width: width,
        child: TextFormField(
          controller: _commentController,
          maxLines: 1,
          maxLength: 250,
          decoration: InputDecoration(
            hintText: _i18n.translate("comment_leave"),
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary)),
            fillColor: Colors.green,
            suffixIcon: IconButton(
              icon: const Icon(Iconsax.send_1),
              onPressed: () {},
            ),
          ),
          validator: (value) {
            if ((value == null) || (value == "")) {
              return _i18n.translate("validation_1_character");
            }
          },
        ));
  }
}
