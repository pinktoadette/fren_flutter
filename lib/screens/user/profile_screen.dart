import 'package:fren_app/api/machi/user_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/dialogs/report_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppLocalizations _i18n;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final double _iconSize = 16;
  final _userApi = UserApi();
  Map<String, dynamic> friendStatus = {
    "status": "UNFRIEND",
    "isRequester": 0,
    "requester": ""
  };
  bool isFrend = false;

  @override
  void initState() {
    _isUserFriend();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _isUserFriend() async {
    final user = await _userApi.getOneFriend(widget.user.userId);
    if (user.isNotEmpty) {
      final friend = user[0]["friends"]
          .where((u) => u['userId'] == widget.user.userId)
          .toList()
          .first;
      final requester = user[0]["friends"]
          .where((u) => u['userId'] != widget.user.userId)
          .toList()
          .first;
      setState(() {
        friendStatus = {
          "status": friend["fstatus"],
          "isRequester": friend["isRequester"],
          "requester": requester["usernamer"]
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: <Widget>[
          // Check the current User ID
          if (UserModel().user.userId != widget.user.userId)
            IconButton(
              icon: Icon(Icons.flag,
                  color: Theme.of(context).primaryColor, size: 32),
              // Report/Block profile dialog
              onPressed: () => ReportDialog(userId: widget.user.userId).show(),
            )
        ],
      ),
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AvatarInitials(user: widget.user),
                      const SizedBox(width: 20),
                      Text(
                        widget.user.userFullname,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      /// Show verified badge
                      widget.user.userIsVerified
                          ? Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: Image.asset(
                                  'assets/images/verified_badge.png',
                                  width: 30,
                                  height: 30))
                          : const SizedBox(width: 0, height: 0),
                    ],
                  ),

                  /// Profile details
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [_buttonDisplay(context)],
                        ),

                        // interest
                        _rowProfileInfo(context,
                            icon: Icon(Iconsax.heart, size: _iconSize),
                            title: widget.user.userInterest.join(", ")),

                        const SizedBox(height: 5),

                        /// indsutry
                        _rowProfileInfo(context,
                            icon: Icon(Iconsax.briefcase, size: _iconSize),
                            title: widget.user.userIndustry),

                        const SizedBox(height: 5),

                        const Divider(),

                        /// Profile bio
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_i18n.translate("bio"),
                              style: Theme.of(context).textTheme.labelLarge),
                        ),
                        Text(widget.user.userBio ?? "",
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _rowProfileInfo(BuildContext context,
      {required Widget icon, required String title}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Flexible(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ))
      ],
    );
  }

  Widget _buttonDisplay(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    _i18n = AppLocalizations.of(context);

    switch (friendStatus["status"]) {
      case 'REQUEST':
        if (friendStatus["isRequester"] == 1) {
          return OutlinedButton(
              onPressed: null, child: Text(_i18n.translate("friend_sent")));
        }
        return Row(
          children: [
            Text(
                "${friendStatus["requester"]}${_i18n.translate("friend_other_sent")}"),
            ElevatedButton(
                onPressed: () {},
                child: Text(_i18n.translate("friend_accept_request"))),
            ElevatedButton(
                onPressed: () {},
                child: Text(_i18n.translate("friend_reject_request"))),
          ],
        );
      case 'ACTIVE':
        return ElevatedButton(
          onPressed: () {},
          child: const Icon(Iconsax.message),
        );
      case 'BLOCK':
        return ElevatedButton(
          onPressed: () {},
          child: const Text("Unblock"),
        );
      default:
        return ElevatedButton.icon(
            onPressed: () async {
              await _userApi.sendRequest(widget.user.userId);
              _isUserFriend();
            },
            icon: const Icon(Iconsax.message),
            label: Text(_i18n.translate("friend_send_request")));
    }
  }
}
