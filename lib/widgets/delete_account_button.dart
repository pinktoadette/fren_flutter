import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/screens/delete_account_screen.dart';
import 'package:machi_app/widgets/button/default_button.dart';
import 'package:flutter/material.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Center(
      child: DefaultButton(
        child: Text(i18n.translate("delete_account"),
            style: const TextStyle(fontSize: 18)),
        onPressed: () {
          /// Delete account
          ///
          /// Confirm dialog
          AlertDialog(
            title: Text(
              i18n.translate("delete_account"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            content: Text(i18n.translate(
                "all_your_profile_data_will_be_permanently_deleted")),
            actions: <Widget>[
              OutlinedButton(
                  onPressed: () => {
                        Navigator.of(context).pop(false),
                      },
                  child: Text(i18n.translate("CANCEL"))),
              const SizedBox(
                width: 50,
              ),
              ElevatedButton(
                  onPressed: () => {
                        Navigator.of(context).pop(),

                        /// Go to delete account screen
                        Future(() {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DeleteAccountScreen()));
                        })
                      },
                  child: Text(i18n.translate("DELETE"))),
            ],
          );
        },
      ),
    );
  }
}
