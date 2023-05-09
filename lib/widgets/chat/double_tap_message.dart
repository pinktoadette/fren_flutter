import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
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
  final _titleController = TextEditingController();
  final _storyApi = StoryApi();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Iconsax.book),
              Text(
                _i18n.translate("storyboard"),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(_i18n.translate("add_to_new_storyboard"))),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: TextFormField(
                  maxLength: 15,
                  buildCounter: (_,
                          {required currentLength,
                          maxLength,
                          required isFocused}) =>
                      _counter(context, currentLength, maxLength),
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
                          onPressed: () async {
                            if (_titleController.text.length < 3) {
                              setState(() {
                                errorMessage =
                                    _i18n.translate("validation_3_characters");
                              });
                            } else {
                              try {
                                await _storyApi.createStory(
                                    _titleController.text, widget.message.id);
                                _titleController.clear();
                                FocusScope.of(context).unfocus();
                              } catch (error) {
                                setState(() {
                                  errorMessage =
                                      _i18n.translate("an_error_has_occurred");
                                });
                              }
                            }
                          },
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
            )),
        Text(errorMessage),
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
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(_i18n.translate("add_to_exist_storyboard"))),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height * 0.5,
                child: ListMyStories(message: widget.message),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Text(
            currentLength.toString() + "/" + maxLength.toString(),
            style: Theme.of(context).textTheme.labelSmall,
          )),
    );
  }
}
