import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:machi_app/models/user_model.dart';
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

  void _fetchRecommend() async {
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

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          Text(
            "${_i18n.translate("hello")} ${UserModel().user.username}!",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 80,
          ),
          Text(
            _i18n.translate("select_up_to_three"),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            _i18n.translate("select_interest"),
            style: Theme.of(context).textTheme.labelMedium,
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
          ElevatedButton(
            child: Text(
              _i18n.translate("DONE"),
            ),
            onPressed: () {
              if (_selectedInterest.length != _numSelection) {
                Get.snackbar(
                  _i18n.translate("validation_warning"),
                  _i18n.translate("select_up_to_three"),
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: APP_ERROR,
                );
              } else {
                _saveUserInterest();
              }
            },
          ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  void _saveUserInterest() async {
    try {
      await UserModel().updateUserData(
          userId: UserModel().user.userId,
          data: {USER_INTERESTS: _selectedInterest});
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } catch (err) {
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
