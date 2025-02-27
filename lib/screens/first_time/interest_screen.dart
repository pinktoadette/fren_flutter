import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/main_binding.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/first_time/steps_counter.dart';
import 'package:machi_app/screens/home_screen.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  UserController userController = Get.put(UserController(), tag: 'user');
  late AppLocalizations _i18n;
  late double _width;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
    _width = MediaQuery.of(context).size.height;
  }

  void _fetchRecommend() async {
    if (!mounted) {
      return;
    }
    String cat =
        await rootBundle.loadString('assets/json/shorten_interest.json');
    List<String> category = List.from(jsonDecode(cat) as List<dynamic>);
    setState(() {
      _category = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Theme.of(context).colorScheme.background)),
            body: Container(
              color: Theme.of(context).colorScheme.background,
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
                    _i18n.translate("select_three"),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    _i18n.translate("select_interest"),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (_category.isNotEmpty)
                    SizedBox(
                        width: _width,
                        child: ChipsChoice<String>.multiple(
                          padding: const EdgeInsets.all(0),
                          value: _selectedInterest,
                          onChanged: (val) =>
                              setState(() => _selectedInterest = val),
                          choiceItems: C2Choice.listFrom<String, String>(
                            source: _category,
                            value: (i, v) => v,
                            label: (i, v) => v,
                            tooltip: (i, v) => v,
                          ),
                          choiceStyle: C2ChipStyle.filled(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
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
                                _i18n.translate("select_three_interest"),
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
            )));
  }

  void _saveUserInterest() async {
    try {
      User user = UserModel().user;

      /// clear timeline from public view
      Get.deleteAll();
      MainBinding mainBinding = MainBinding();
      await mainBinding.dependencies();

      UserModel().updateUserData(
          userId: user.userId,
          data: {USER_INTERESTS: _selectedInterest}).then((_) {
        debugPrint('Save interest');

        userController.updateUser(user);
      });

      Get.offAll(() => const HomeScreen());
    } catch (err, s) {
      Get.snackbar(
          _i18n.translate("Error"), _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
          colorText: Colors.black);
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error saving users interest', fatal: false);
    }
  }
}
