import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/announcement.dart';

class InlineSurvey extends StatefulWidget {
  const InlineSurvey({super.key});

  @override
  _InlineSurveyState createState() => _InlineSurveyState();
}

class _InlineSurveyState extends State<InlineSurvey> {
  final _announceApi = AnnouncementApi();
  dynamic survey;
  String? _choice;

  @override
  void initState() {
    super.initState();
    _getSurvey();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getSurvey() async {
    final res = await _announceApi.getAnnounce();
    setState(() {
      survey = res[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (survey == null) {
      return const SizedBox.shrink();
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
                  value: choice["value"],
                  groupValue: _choice,
                  onChanged: (value) {
                    setState(() {
                      _choice = value;
                    });
                  },
                ),
              );
            }).toList(),
            ElevatedButton(onPressed: () {}, child: const Text("Submit"))
          ],
        ));
  }
}
