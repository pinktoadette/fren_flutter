import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/announcement.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class InlineSurvey extends StatefulWidget {
  const InlineSurvey({super.key});

  @override
  _InlineSurveyState createState() => _InlineSurveyState();
}

class _InlineSurveyState extends State<InlineSurvey>
    with AutomaticKeepAliveClientMixin {
  final _announceApi = AnnouncementApi();
  late AppLocalizations _i18n;
  dynamic survey;
  String? _choice;
  bool? isComplete = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getSurvey();
  }

  void _getSurvey() async {
    final res = await _announceApi.getAnnounce();
    if (res.isNotEmpty) {
      setState(() {
        survey = res[0];
      });
    }
  }

  void _postSurveyResponse() async {
    try {
      await _announceApi.responseToSurvey(
          announceId: survey['announceId'], choiceId: _choice!);
      setState(() {
        isComplete = true;
      });
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot save users survey response ${err.toString()}',
          fatal: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (survey == null) {
      return const SizedBox.shrink();
    } else if (isComplete == true) {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    "Thank you",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "If you have more suggestions, you can fill out this google form.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(SURVEY_FORM);
                        await launchUrl(url);
                      },
                      child: const Text("Suggestion Form"))
                ],
              )));
    }
    return Card(
        color: APP_ACCENT_COLOR,
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  survey['title'],
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                Text(survey["body"],
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                ...survey["choices"].map((choice) {
                  return ListTile(
                    title: Text(choice["value"],
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16)),
                    leading: Radio(
                      activeColor: APP_LIKE_COLOR,
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
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    onPressed: () {
                      _postSurveyResponse();
                    },
                    child: const Text("Submit"))
              ],
            )));
  }
}
