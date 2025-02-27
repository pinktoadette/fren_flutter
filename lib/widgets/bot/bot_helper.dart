import 'package:chips_choice/chips_choice.dart';
import 'package:dio/dio.dart';
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
  State<MachiHelper> createState() => _MachiHelperState();
}

class _MachiHelperState extends State<MachiHelper> {
  late AppLocalizations _i18n;
  late Size size;
  final _cancelToken = CancelToken();
  String? _response;
  String? tag;
  bool _isLoading = false;
  List<Map<String, String>> options = [
    {'action': 'shorten', 'value': 'machi_helper_shorten_text'},
    {'action': 'rephrase', 'value': 'machi_helper_rephrase_text'},
    {'action': 'an idea to make better', 'value': 'machi_helper_get_ideas'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
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
                    : const SizedBox(
                        width: 20,
                      ),
                SizedBox(
                    width: size.width - 60,
                    child: Text(
                      truncateText(maxLength: 300, text: widget.text),
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
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String response = "No text";
    if (widget.text != "") {
      final botApi = BotApi();
      response = await botApi.machiHelper(
          text: widget.text, action: action, cancelToken: _cancelToken);
    }
    if (mounted) {
      setState(() {
        _response = response;
        _isLoading = false;
      });
    }
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
