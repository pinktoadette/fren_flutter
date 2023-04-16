import 'package:flutter/material.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fren_app/widgets/storyboard/add_storyboard.dart';
import 'package:fren_app/widgets/storyboard/list_my_story.dart';
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
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _i18n.translate("story_share_message"),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(_i18n.translate("add_to_new_storyboard")),
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
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
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
            const SizedBox(
              height: 15,
            ),
            const Row(children: [
              Expanded(child: Divider(thickness: 1.5)),
              Text("OR", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Expanded(child: Divider(thickness: 1.5)),
            ]),
            const SizedBox(
              height: 15,
            ),
            Text(_i18n.translate("add_to_exist_storyboard")),
            SizedBox(
              height: height - 200,
              child: const MyStories(),
            )
          ],
        ));
  }
}
