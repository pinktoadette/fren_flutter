import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteCard extends StatefulWidget {
  const InviteCard({Key? key}) : super(key: key);

  @override
  InviteCardState createState() => InviteCardState();
}

class InviteCardState extends State<InviteCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    double screenWidth = MediaQuery.of(context).size.width;
    final _i18n = AppLocalizations.of(context);

    return SizedBox(
      height: 100,
      width: screenWidth,
      child: InkWell(
        onTap: () {
          _showQRSheet();
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_i18n.translate("invite_user"),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 10),
          const Icon(Iconsax.scan_barcode),
        ]),
      ),
    );
  }

  void _showQRSheet() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String myUrl =
        "https://mymachi.app/u/dfsfsdsdfsdfsdfdsfsdfsdfsdfsdfsdfsdfsd${UserModel().user.userFullname}";

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (BuildContext context) {
        return Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).copyWith().size.height,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(UserModel().user.userFullname,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              Text("@${UserModel().user.userFullname}",
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                              const SizedBox(height: 10),
                              QrImage(
                                data: myUrl,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.copy),
                          SelectableText("@${UserModel().user.userFullname}",
                              showCursor: false, onTap: () {
                            showScaffoldMessage(
                                message: "Copied",
                                bgcolor: Theme.of(context).primaryColor);
                          },
                              toolbarOptions: const ToolbarOptions(
                                  copy: true,
                                  selectAll: true,
                                  cut: false,
                                  paste: false),
                              style: Theme.of(context).textTheme.labelSmall)
                        ],
                      )
                    ],
                  )),
            ]),
          ),
        );
      },
    );
  }
}
