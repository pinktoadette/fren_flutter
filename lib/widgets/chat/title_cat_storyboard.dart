import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/forms/category_dropdown.dart';

/// Create or update title and category
/// requires callback to parent to either create or update
class StoryboardTitleCategory extends StatefulWidget {
  final String? title;
  final String? category;
  final Function(dynamic data) onUpdate;

  const StoryboardTitleCategory(
      {Key? key, required this.onUpdate, this.title, this.category})
      : super(key: key);

  @override
  State<StoryboardTitleCategory> createState() =>
      _StoryboardTitleCategoryState();
}

class _StoryboardTitleCategoryState extends State<StoryboardTitleCategory> {
  late AppLocalizations _i18n;
  final _titleController = TextEditingController();
  String errorMessage = '';
  String _selectedCategory = "";

  @override
  void initState() {
    if (widget.title != null) _titleController.text = widget.title!;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = MediaQuery.of(context).size.width;

      return Card(
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width,
                    child: widget.category == ""
                        ? CategoryDropdownWidget(notifyParent: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          })
                        : CategoryDropdownWidget(
                            selectedCategory: widget.category,
                            notifyParent: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }),
                  ),
                  TextFormField(
                    maxLength: 80,
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
                      hintText: _i18n.translate("creative_mix_title"),
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (reason) {
                      // Basic validation
                      if (reason?.isEmpty ?? false) {
                        return _i18n.translate("creative_mix_enter_title");
                      }
                      return null;
                    },
                  ),
                ],
              )));
    });
  }

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Column(children: [
            Text(errorMessage),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$currentLength/$maxLength",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.length < 3) {
                        setState(() {
                          errorMessage =
                              _i18n.translate("validation_3_characters");
                        });
                      } else {
                        widget.onUpdate({
                          'title': _titleController.text,
                          'category': _selectedCategory,
                        });
                        _titleController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Text(
                      _i18n.translate("SAVE"),
                      style: const TextStyle(fontSize: 14),
                    )),
              ],
            )
          ])),
    );
  }
}
