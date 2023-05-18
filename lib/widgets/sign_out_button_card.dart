import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/sign_in_screen.dart';
import 'package:machi_app/widgets/common/default_card_border.dart';
import 'package:flutter/material.dart';

class SignOutButtonCard extends StatelessWidget {
  const SignOutButtonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: defaultCardBorder(),
      child: ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: Text(i18n.translate("sign_out"),
            style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
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
      ),
    );
  }
}
