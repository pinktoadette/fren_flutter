import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/sign_out_button_card.dart';
import 'package:scoped_model/scoped_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hideProfile = false;
  bool _isDarkMode = false;
  late AppLocalizations _i18n;

  /// Initialize user settings
  void initUserSettings() async {
    bool isDarkMode = ThemeHelper().loadThemeFromBox();
    setState(() {
      // Check profile status
      if (UserModel().user.userStatus == 'hidden') {
        _hideProfile = true;
      }
      _isDarkMode = isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    initUserSettings();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            _i18n.translate("settings"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: Container(
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ScopedModelDescendant<UserModel>(
              builder: (context, child, userModel) {
            return Column(
              children: [
                /// Hide user profile setting
                ListTile(
                  leading: _hideProfile
                      ? Icon(Icons.visibility_off,
                          color: Theme.of(context).primaryColor, size: 30)
                      : Icon(Icons.visibility,
                          color: Theme.of(context).primaryColor, size: 30),
                  title: Text(_i18n.translate('hide_profile'),
                      style: const TextStyle(fontSize: 18)),
                  trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: _hideProfile,
                    onChanged: (newValue) {
                      // Update UI
                      setState(() {
                        _hideProfile = newValue;
                      });
                      // User status
                      String userStatus = 'active';
                      // Check status
                      if (newValue) {
                        userStatus = 'hidden';
                      }

                      // Update profile status
                      UserModel().updateUserData(
                          userId: UserModel().user.userId,
                          data: {USER_STATUS: userStatus}).then((_) {
                        debugPrint('Profile hidden: $newValue');
                      });
                    },
                  ),
                ),

                /// dark mode
                // const SizedBox(height: 15),
                // ListTile(
                //   leading: _isDarkMode
                //       ? Icon(Iconsax.sun,
                //           color: Theme.of(context).primaryColor, size: 30)
                //       : Icon(Iconsax.moon,
                //           color: Theme.of(context).primaryColor, size: 30),
                //   title: Text(_i18n.translate('dark_mode'),
                //       style: const TextStyle(fontSize: 18)),
                //   subtitle: Text(_i18n.translate('enable_mode')),
                //   trailing: Switch(
                //     activeColor: Theme.of(context).colorScheme.secondary,
                //     value: _isDarkMode,
                //     onChanged: (newValue) async {
                //       // Update UI
                //       setState(() {
                //         _isDarkMode = newValue;
                //       });

                //       /// GetX storage
                //       ThemeHelper().switchTheme();

                //       // Update profile status
                //       UserModel().updateUserData(
                //           userId: UserModel().user.userId,
                //           data: {USER_DARK_MODE: newValue}).then((_) {
                //         debugPrint('dark mode: $newValue');
                //       });
                //     },
                //   ),
                // ),

                const Spacer(),

                /// sign out
                const SignOutButtonCard(),
              ],
            );
          }),
        ));
  }
}
