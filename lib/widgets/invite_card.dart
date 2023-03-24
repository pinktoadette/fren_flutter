import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/screens/user/invite_contact_screen.dart';
import 'package:fren_app/widgets/bot/tiny_bot.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => const InviteContactScreen()));
      Get.to(() => const InviteContactScreen());
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      showScaffoldMessage(
          message: 'Access to contact data denied', bgcolor: APP_ERROR);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      showScaffoldMessage(
          message: 'Contact data not available on device', bgcolor: APP_ERROR);
    }
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
          _askPermissions();
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const TinyBotIcon(image: "assets/images/pink_bot.png"),
          Text(_i18n.translate("invite_user"),
              style: Theme.of(context).textTheme.titleMedium)
        ]),
      ),
    );
  }
}
