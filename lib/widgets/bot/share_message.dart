import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:iconsax/iconsax.dart';

class ShareMessage extends StatefulWidget {
  final types.Message message;
  const ShareMessage({Key? key, required this.message}) : super(key: key);

  @override
  _ShareMessageState createState() => _ShareMessageState();
}

class _ShareMessageState extends State<ShareMessage> {
  final Map<String, dynamic>? _userSettings = UserModel().user.userSettings;
  late AppLocalizations _i18n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print(widget.message);

    return Center(
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        child: SizedBox(
          width: screenWidth,
          height: screenHeight / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Iconsax.box_tick),
                title: const Text("Share Message"),
                subtitle: Text(widget.message.id),
              ),
              Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(widget.message.id),
                        )
                    ),
                  ]
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Text(_i18n.translate("CANCEL")),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      onPressed: () {  },
                      child: const Text("Contribute"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


}
