import 'package:machi_app/api/machi/friend_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/dialogs/report_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:get/get.dart';
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
  final _friendApi = FriendApi();
  final _timelineApi = TimelineApi();
  ChatController chatController = Get.find(tag: 'chatroom');

  Map<String, dynamic> friendStatus = {
    "status": "UNFRIEND",
    "isRequester": 0,
    "requester": ""
  };
  List<Storyboard> boards = [];
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

  Future<List<Storyboard>> _getUserBoard() async {
    /// @todo need infinite
    List<Storyboard> newItems =
        await _timelineApi.getTimelineByPageUserId(widget.user.userId);
    return newItems;
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
    double height = MediaQuery.of(context).size.height;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (UserModel().user.userStatus == "hidden")
                    const Text("Your profile is hidden"),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
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
                            const Row(
                              children: [
                                Text("123 \nFollowes"),
                                SizedBox(width: 10),
                                Text("431 \nFollowing"),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_followButton(), _friendRequest(context)],
                    ),
                  ),

                  /// Profile details
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    height: height * 0.1,
                    child: Text(widget.user.userBio ?? "",
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),

                  _userPost()
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _userPost() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if ((widget.user.userStatus == "hidden") &
        (widget.user.userId != UserModel().user.userId)) {
      return NoData(text: _i18n.translate("profile_nothing"));
    }

    return SizedBox(
        height: height * 0.8,
        width: width,
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Storyboard item = snapshot.data![index];
                return StoryboardItemWidget(item: item);
              },
            );
          },
          future: _getUserBoard(),
        ));
  }

  Widget _followButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        _friendApi
            .sendRequest(widget.user.userId)
            .then((_) => {_isUserFriend()});
      },
      icon: const Icon(Icons.check),
      label: Text(_i18n.translate("follow")),
    );
  }

  Widget _friendRequest(BuildContext context) {
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
        return OutlinedButton.icon(
          onPressed: () async {
            _friendApi
                .sendRequest(widget.user.userId)
                .then((_) => {_isUserFriend()});
          },
          icon: const Icon(Iconsax.message),
          label: Text(_i18n.translate("friend_send_request")),
        );
    }
  }
}
