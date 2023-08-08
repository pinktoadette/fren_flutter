import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

class MachiHelper extends StatefulWidget {
  final String text;

  final Function(String replace) onTextReplace;
  const MachiHelper({Key? key, required this.text, required this.onTextReplace})
      : super(key: key);

  @override
  _MachiHelperState createState() => _MachiHelperState();
}

class _MachiHelperState extends State<MachiHelper> {
  late AppLocalizations _i18n;
  String? _response;
  String? tag;
  bool _isLoading = false;
  List<Map<String, String>> options = [
    {'action': 'shorten', 'value': 'machi_helper_shortern_text'},
    {'action': 'rephrase', 'value': 'machi_helper_rephrase_text'},
    {'action': 'ideas to make better', 'value': 'machi_helper_get_ideas'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    /// Initialization
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.all(5),
        width: size.width,
        child: Column(
          children: [
            Row(
              children: [
                ChipsChoice<String>.single(
                  value: tag,
                  onChanged: (val) {
                    _getHelperResponse(action: val);
                    setState(() {
                      tag = val;
                    });
                  },
                  choiceItems: C2Choice.listFrom<String, dynamic>(
                    source: options,
                    value: (i, item) => item["action"],
                    label: (i, item) =>
                        _i18n.translate(item["value"] as String),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _isLoading == true
                    ? loadingButton(size: 20, color: APP_ACCENT_COLOR)
                    : const SizedBox.shrink(),
                SizedBox(
                    width: size.width - 60,
                    child: Text(
                      truncateText(maxLength: 90, text: widget.text),
                      style: Theme.of(context).textTheme.bodySmall,
                    ))
              ],
            ),
            const Divider(
              height: 10,
            ),
            if (_response != null) ..._showResponse()
          ],
        ));
  }

  void _getHelperResponse({required String action}) async {
    setState(() {
      _isLoading = true;
    });
    String response = "No text";
    if (widget.text != "") {
      final _botApi = BotApi();
      response = await _botApi.machiHelper(text: widget.text, action: action);
    }

    setState(() {
      _response = response;
      _isLoading = false;
    });
  }

  List<Widget> _showResponse() {
    return [
      Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _response!,
          )),
      ElevatedButton(
          onPressed: () {
            widget.onTextReplace(_response!);
          },
          child: Text(_i18n.translate("machi_helper_replace_text")))
    ];
  }
}
