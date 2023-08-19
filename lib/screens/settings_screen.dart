import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/account_page.dart';
import 'package:machi_app/widgets/sign_out_button_card.dart';
import 'package:scoped_model/scoped_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AppLocalizations _i18n;
  late double _height;
  bool _hideProfile = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initUserSettings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
    _height = MediaQuery.of(context).size.height;
  }

  /// Initialize user settings
  void initUserSettings() async {
    if (!mounted) {
      return;
    }

    ThemeMode themeMode = ThemeHelper().themeMode;
    bool isDarkMode = themeMode == ThemeMode.dark;

    setState(() {
      // Check profile status
      if (UserModel().user.userStatus == 'hidden') {
        _hideProfile = true;
      }
      _isDarkMode = isDarkMode;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leadingWidth: 20,
          centerTitle: false,
          title: Text(
            _i18n.translate("settings"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: Container(
          height: _height,
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
                  title: Text(_i18n.translate('protected_profile'),
                      style: const TextStyle(fontSize: 18)),
                  subtitle: Text(
                    _i18n.translate("protected_profile_notes"),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
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
                const SizedBox(height: 15),
                ListTile(
                  leading: _isDarkMode
                      ? Icon(Iconsax.moon,
                          color: Theme.of(context).primaryColor, size: 30)
                      : Icon(Iconsax.sun,
                          color: Theme.of(context).primaryColor, size: 30),
                  title: Text(_i18n.translate('dark_mode'),
                      style: const TextStyle(fontSize: 18)),
                  subtitle: Text(_i18n.translate('enable_mode')),
                  trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: _isDarkMode,
                    onChanged: (newValue) async {
                      // Update UI
                      setState(() {
                        _isDarkMode = newValue;
                      });

                      /// GetX storage
                      ThemeHelper().toggleTheme();

                      // Update profile status
                      UserModel().updateUserData(
                          userId: UserModel().user.userId,
                          data: {USER_DARK_MODE: newValue}).then((_) {
                        debugPrint('dark mode: $newValue');
                      });
                    },
                  ),
                ),

                const Spacer(),

                /// deactivate
                ListTile(
                  leading: const Icon(Iconsax.setting_2),
                  title: Text(_i18n.translate("account"),
                      style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () async {
                    Get.to(() => const AccountPage());
                  },
                ),

                /// sign out
                const SignOutButtonCard(),
                const SizedBox(
                  height: 50,
                )
              ],
            );
          }),
        ));
  }
}
