import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditText extends StatefulWidget {
  final String? text;
  final Function(String?) onTextComplete;
  const AddEditText({Key? key, required this.onTextComplete, this.text})
      : super(key: key);

  @override
  _AddEditTextState createState() => _AddEditTextState();
}

class _AddEditTextState extends State<AddEditText> {
  late AppLocalizations _i18n;
  late TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    if (widget.text != null) {
      _textController = TextEditingController(text: widget.text);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
        height: height * 0.9,
        padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_i18n.translate("story_add_text_scene"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  ElevatedButton(
                      onPressed: () {
                        _onComplete(_textController.text);
                      },
                      child: Text(_i18n.translate("add")))
                ],
              ),
              SizedBox(
                  width: width,
                  child: TextFormField(
                    maxLength: 500,
                    maxLines: 10,
                    buildCounter: (_,
                            {required currentLength,
                            maxLength,
                            required isFocused}) =>
                        _counter(context, currentLength, maxLength),
                    controller: _textController,
                  ))
            ]));
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

  void _onComplete(String text) {
    if (text.length < 3) {
      Get.snackbar(
        _i18n.translate("validation_warning"),
        _i18n.translate("validation_3_characters"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_WARNING,
      );
    } else {
      widget.onTextComplete(text);
    }
  }
}
