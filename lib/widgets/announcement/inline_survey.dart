import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:machi_app/api/machi/announcement.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';

class InlineSurvey extends StatefulWidget {
  const InlineSurvey({super.key});

  @override
  _InlineSurveyState createState() => _InlineSurveyState();
}

class _InlineSurveyState extends State<InlineSurvey> {
  final _announceApi = AnnouncementApi();
  late AppLocalizations _i18n;
  dynamic survey;
  String? _choice;
  bool? isComplete = false;

  @override
  void initState() {
    super.initState();
    _getSurvey();
  }

  void _getSurvey() async {
    final res = await _announceApi.getAnnounce();
    setState(() {
      survey = res[0];
    });
  }

  void _postSurveyResponse() async {
    try {
      await _announceApi.responseToSurvey(
          announceId: survey['announceId'], choiceId: _choice!);
      setState(() {
        isComplete = true;
      });
    } catch (err) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (survey == null) {
      return const SizedBox.shrink();
    } else if (isComplete == true) {
      return const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.center,
            child: Text("Thank you"),
          ));
    }
    return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              survey['title'],
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(survey["body"], style: Theme.of(context).textTheme.bodyMedium),
            ...survey["choices"].map((choice) {
              return ListTile(
                title: Text(choice["value"],
                    style: Theme.of(context).textTheme.bodySmall),
                leading: Radio(
                  value: choice["id"],
                  groupValue: _choice,
                  onChanged: (value) {
                    setState(() {
                      _choice = value;
                    });
                  },
                ),
              );
            }).toList(),
            ElevatedButton(
                onPressed: () {
                  _postSurveyResponse();
                },
                child: const Text("Submit"))
          ],
        ));
  }
}
