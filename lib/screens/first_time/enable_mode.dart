import 'package:fren_app/screens/first_time/update_location_sceen.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/rounded_top.dart';
import 'package:iconsax/iconsax.dart';

class EnableMode extends StatefulWidget {
  const EnableMode({Key? key}) : super(key: key);

  @override
  _EnableModeState createState() => _EnableModeState();
}

class _EnableModeState extends State<EnableMode> {
  // Variables
  late AppLocalizations _i18n;
  List<ModeList> listRec = [];
  int selectedIndex = 0;
  Map<String, bool> values = {
    USER_ENABLE_DATE: true,
    USER_ENABLE_SERV: true,
  };

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UpdateLocationScreen()),
          (route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  _setSelection(String key, bool value) {
    setState(() {
      values[key] = value;
    });
  }

  _updateEnable() async {
    String userId = UserModel().user.userId;
    Map<String, Map<String, bool>> data = {USER_ENABLE_MODE: values};
    await UserModel().updateUserData(userId: userId, data: data);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UpdateLocationScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    listRec = [
      ModeList(
          title: Text(_i18n.translate('enable_mode_dates_title')),
          subtitle: Text(
            _i18n.translate('enable_mode_dates_subtitle'),
            style: const TextStyle(fontSize: 12),
          ),
          type: USER_ENABLE_DATE,
          icon: const Icon(Iconsax.like)),
      ModeList(
          title: Text(_i18n.translate('enable_mode_service_title')),
          subtitle: Text(_i18n.translate('enable_mode_service_subtitle'),
              style: const TextStyle(fontSize: 12)),
          type: USER_ENABLE_SERV,
          icon: const Icon(Iconsax.briefcase)),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          const RoundedTop(),
          Center(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Text(_i18n.translate('enable_mode'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.left),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Text(_i18n.translate('enable_mode_des'),
                  textAlign: TextAlign.left),
            ),
            Container(
              //Added the color here
              margin: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: 2,
                itemBuilder: (context, int index) {
                  return Container(
                      height: 100,
                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.background,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff131200).withOpacity(0.20),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(
                                3, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        title: listRec[index].title,
                        subtitle: listRec[index].subtitle,
                        onChanged: (bool? value) {
                          _setSelection(listRec[index].type, value!);
                        },
                        secondary: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: listRec[index].icon,
                        ),
                        value: values[listRec[index].type],
                      ));
                },
              ),
            ),
            ElevatedButton(
                child: Text(_i18n.translate('enable')),
                onPressed: () async {
                  _updateEnable();
                })
          ])),
        ]),
      ),
    );
  }
}

class ModeList {
  late Text title;
  late final Text subtitle;
  late String type;
  late Icon icon;

  ModeList(
      {required this.title,
      required this.subtitle,
      required this.type,
      required this.icon});
}
