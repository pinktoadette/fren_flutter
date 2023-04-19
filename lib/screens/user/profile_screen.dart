import 'package:fren_app/api/machi/friend_api.dart';
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
  final _friendApi = FriendApi();
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
    final user = await _friendApi.getOneFriend(widget.user.userId);
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
          "requester": requester["username"]
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
              icon: Icon(Iconsax.flag,
                  color: Theme.of(context).primaryColor, size: 24),
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
                      AvatarInitials(
                        userId: widget.user.userId,
                        username: widget.user.username,
                        photoUrl: widget.user.userProfilePhoto,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.username,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 10),
                          _buttonDisplay(context)
                        ],
                      )
                    ],
                  ),

                  /// Profile details
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    switch (friendStatus["status"]) {
      case 'REQUEST':
        if (friendStatus["isRequester"] == 1) {
          return OutlinedButton(
              onPressed: null,
              child: Text(
                _i18n.translate("friend_sent"),
                style: Theme.of(context).textTheme.labelSmall,
              ));
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width - 130,
                  child: Flexible(
                    fit: FlexFit.tight,
                    child: Text(_i18n.translate("friend_other_sent"),
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _friendApi
                              .respondRequest(
                                  widget.user.userId, FriendStatus.active)
                              .then((_) => {_isUserFriend()});
                        },
                        child: Text(
                          _i18n.translate("friend_accept_request"),
                          style: const TextStyle(fontSize: 12),
                        )),
                    OutlinedButton(
                        onPressed: () {
                          _friendApi
                              .respondRequest(
                                  widget.user.userId, FriendStatus.unfriend)
                              .then((_) => {_isUserFriend()});
                        },
                        child: Text(
                          _i18n.translate("friend_reject_request"),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)))),
                  ],
                )
              ],
            )
          ],
        );
      case 'ACTIVE':
        return const SizedBox.shrink();
      case 'BLOCK':
        return const SizedBox.shrink();
      default:
        return ElevatedButton.icon(
            onPressed: () async {
              _friendApi
                  .sendRequest(widget.user.userId)
                  .then((_) => {_isUserFriend()});
            },
            icon: const Icon(Iconsax.message),
            label: Text(
              _i18n.translate("friend_send_request"),
              style: const TextStyle(fontSize: 12),
            ));
    }
  }
}
