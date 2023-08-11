import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/storyboard/my_items/list_my_board.dart';
import 'package:iconsax/iconsax.dart';

class AddStoryBoard extends StatefulWidget {
  final types.Message message;
  const AddStoryBoard({Key? key, required this.message}) : super(key: key);

  @override
  State<AddStoryBoard> createState() => _AddStoryBoardState();
}

class _AddStoryBoardState extends State<AddStoryBoard> {
  late AppLocalizations _i18n;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Add to storyboard"),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: _i18n.translate("story_title"),
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Iconsax.add),
                      label: Text(_i18n.translate("add")))),
              validator: (reason) {
                // Basic validation
                if (reason?.isEmpty ?? false) {
                  return _i18n.translate("story_enter_title");
                }
                return null;
              },
            )),
          ],
        ),
        const Scrollbar(
            child: SingleChildScrollView(
          child: ListPrivateBoard(),
        ))
      ],
    );
  }
}
