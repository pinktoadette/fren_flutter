import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/processing.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/button/default_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterScreen> {
  late AppLocalizations _i18n;
  late UserModel users;

  @override
  void initState() {
    super.initState();
    _fetchRecommendUsers();
  }

  void _fetchRecommendUsers() async {}

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Follow users with similar interest"),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text(
                _i18n.translate("done"),
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
