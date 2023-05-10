import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/forms/category_dropdown.dart';

class AddNewStoryboard extends StatefulWidget {
  types.Message message;
  AddNewStoryboard({Key? key, required this.message}) : super(key: key);

  @override
  _AddNewStoryboardState createState() => _AddNewStoryboardState();
}

class _AddNewStoryboardState extends State<AddNewStoryboard> {
  late AppLocalizations _i18n;
  final _titleController = TextEditingController();
  final _storyApi = StoryApi();
  String errorMessage = '';
  String _selectedCategory = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              _i18n.translate("add_to_new_storyboard"),
              style: Theme.of(context).textTheme.headlineSmall,
            )),
        SizedBox(
          width: width,
          child: CategoryDropdownWidget(notifyParent: (value) {
            setState(() {
              _selectedCategory = value;
            });
          }),
        ),
        TextFormField(
          maxLength: 20,
          buildCounter: (_,
                  {required currentLength, maxLength, required isFocused}) =>
              _counter(context, currentLength, maxLength),
          controller: _titleController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: _i18n.translate("story_title"),
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          validator: (reason) {
            // Basic validation
            if (reason?.isEmpty ?? false) {
              return _i18n.translate("story_enter_title");
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentLength.toString() + "/" + maxLength.toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              ElevatedButton.icon(
                  onPressed: () async {
                    if (_titleController.text.length < 3) {
                      setState(() {
                        errorMessage =
                            _i18n.translate("validation_3_characters");
                      });
                    } else {
                      try {
                        await _storyApi.createStory(_titleController.text,
                            _selectedCategory, widget.message.id);
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
                  label: Text(_i18n.translate("add"))),
              Text(errorMessage),
            ],
          )),
    );
  }
}
