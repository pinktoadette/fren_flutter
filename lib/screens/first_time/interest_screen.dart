import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/steps_counter.dart';
import 'package:machi_app/screens/home_screen.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

  @override
  _InterestScreenState createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  late AppLocalizations _i18n;
  List<String> _category = [];
  List<String> _selectedInterest = [];
  final usersMemoizer = C2ChoiceMemoizer<String>();
  final int _numSelection = 3;
  @override
  void initState() {
    super.initState();
    _fetchRecommend();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchRecommend() async {
    if (!mounted) {
      return;
    }
    String _cat =
        await rootBundle.loadString('assets/json/shorten_interest.json');
    List<String> category = List.from(jsonDecode(_cat) as List<dynamic>);
    setState(() {
      _category = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Container(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepCounterSignup(step: 3),
          Text(
            "Ok, ${UserModel().user.username}. Last step!",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            _i18n.translate("select_up_to_three"),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Text(
            _i18n.translate("select_interest"),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(
            height: 20,
          ),
          if (_category.isNotEmpty)
            SizedBox(
                width: width,
                child: ChipsChoice<String>.multiple(
                  value: _selectedInterest,
                  onChanged: (val) => setState(() => _selectedInterest = val),
                  choiceItems: C2Choice.listFrom<String, String>(
                    source: _category,
                    value: (i, v) => v,
                    label: (i, v) => v,
                    tooltip: (i, v) => v,
                  ),
                  choiceStyle: C2ChipStyle.filled(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    selectedStyle: const C2ChipStyle(
                      backgroundColor: APP_ACCENT_COLOR,
                    ),
                  ),
                  choiceCheckmark: true,
                  wrapped: true,
                )),
          const Spacer(),
          Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text(
                  _i18n.translate("DONE"),
                ),
                onPressed: () {
                  if (_selectedInterest.length != _numSelection) {
                    Get.snackbar(_i18n.translate("validation_warning"),
                        _i18n.translate("select_up_to_three"),
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: APP_WARNING,
                        colorText: Colors.black);
                  } else {
                    _saveUserInterest();
                  }
                },
              )),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    ));
  }

  void _saveUserInterest() async {
    try {
      await UserModel().updateUserData(
          userId: UserModel().user.userId,
          data: {USER_INTERESTS: _selectedInterest});
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error saving users interest', fatal: true);
    }
  }
}
