import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:machi_app/api/machi/report_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class ReportForm extends StatefulWidget {
  final String itemId;
  final String itemType;

  const ReportForm({Key? key, required this.itemId, required this.itemType})
      : super(key: key);
  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  late AppLocalizations _i18n;
  final _reportApi = ReportApi();
  final TextEditingController _commentController = TextEditingController();
  List<String> _category = [];
  final List<String> _selectedCategory = [];

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  void _getCategory() async {
    if (!mounted) {
      return;
    }
    String cat = await rootBundle.loadString('assets/json/report.json');
    List<String> category = List.from(jsonDecode(cat) as List<dynamic>);
    setState(() {
      _category = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            _i18n.translate("report_create"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _category.length,
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                    value: _selectedCategory.contains(_category[index]),
                    onChanged: (selected) {
                      if (selected == true) {
                        setState(() {
                          _selectedCategory.add(_category[index]);
                        });
                      } else {
                        setState(() {
                          _selectedCategory.remove(_category[index]);
                        });
                      }
                    },
                    title: Text(_category[index]));
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: _commentController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: _i18n.translate("report_comment"),
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                    onPressed: () {
                      _submitReport();
                    },
                    child: Text(_i18n.translate("submit"))))
          ],
        ));
  }

  void _submitReport() async {
    if (_selectedCategory.isEmpty) {
      Get.snackbar(
        _i18n.translate("validation_warning"),
        _i18n.translate("validation_select_1"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      return;
    }
    try {
      await _reportApi.reportContent(
          itemId: widget.itemId,
          itemType: widget.itemType,
          reason: _selectedCategory.join(", "),
          comments: _commentController.text);

      Get.snackbar(_i18n.translate("success"), _i18n.translate("submitted"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
      Get.back(result: true);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot submit a report', fatal: true);
    }
  }
}
