import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';
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
    return InkWell(
      onTap: () {
        _showQRSheet();
      },
      child: const Icon(Iconsax.scan_barcode),
    );
  }

  void _showQRSheet() {
    double height = MediaQuery.of(context).size.height;
    String myUrl = "https://mymachi.app/u/${UserModel().user.userFullname}";

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: SizedBox(
            height: height,
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
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
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
                            Get.snackbar(
                              'Copied',
                              "Copied successfully!",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: APP_ACCENT_COLOR,
                            );
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
