import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/sign_out_button_card.dart';
import 'package:iconsax/iconsax.dart';
import 'package:place_picker/place_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fren_app/screens/sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hideProfile = false;
  bool _isDarkMode = false;
  late AppLocalizations _i18n;

  /// Initialize user settings
  void initUserSettings() {
    // Get user settings
    // Update variables state
    setState(() {
      // Check profile status
      if (UserModel().user.userStatus == 'hidden') {
        _hideProfile = true;
      }
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
          title: Text(_i18n.translate("settings")),
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
                  subtitle: _hideProfile
                      ? Text(
                          _i18n.translate(
                              'your_profile_is_hidden_on_discover_tab'),
                          style: const TextStyle(color: Colors.red),
                        )
                      : Text(
                          _i18n.translate(
                              'your_profile_is_visible_on_discover_tab'),
                          style: const TextStyle(color: Colors.green)),
                  trailing: Switch(
                    activeColor: Theme.of(context).primaryColor,
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
                const SizedBox(height: 15),
                ListTile(
                  leading: _isDarkMode
                      ? Icon(Iconsax.sun,
                          color: Theme.of(context).primaryColor, size: 30)
                      : Icon(Iconsax.moon,
                          color: Theme.of(context).primaryColor, size: 30),
                  title: Text(_i18n.translate('dark_mode'),
                      style: const TextStyle(fontSize: 18)),
                  subtitle: Text(_i18n.translate('enable_mode')),
                  trailing: Switch(
                    activeColor: Theme.of(context).primaryColor,
                    value: _isDarkMode,
                    onChanged: (newValue) {
                      // Update UI
                      setState(() {
                        _isDarkMode = newValue;
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

                const SizedBox(height: 15),
                const Spacer(),

                /// sign out
                const SignOutButtonCard(),
              ],
            );
          }),
        ));
  }
}
