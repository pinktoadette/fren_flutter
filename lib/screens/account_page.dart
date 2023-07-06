import 'package:get/get.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/sign_in_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  void _deactivate() async {
    try {
      final _userApi = UserApi();
      await _userApi.deactivateAccount();
      await Purchases.logOut();
    } catch (err) {
      Get.snackbar(
        "Error",
        "An error occurred",
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    late AppLocalizations _i18n;

    _i18n = AppLocalizations.of(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            _i18n.translate("account"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: Column(
          children: [
            ListTile(
              title: Text(_i18n.translate("deactivate")),
              subtitle: Text(_i18n.translate("deactivate_info")),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  _deactivate();
                  // Log out button
                  UserModel().signOut().then((_) {
                    /// Go to login screen
                    Future(() {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SignInScreen()));
                    });
                  });
                },
                child: Text(_i18n.translate("deactivate"))),
            const SizedBox(
              height: 50,
            )
          ],
        ));
  }
}
