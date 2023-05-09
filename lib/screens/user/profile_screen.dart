import 'package:machi_app/api/machi/friend_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/timeline.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/dialogs/report_dialog.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/no_data.dart';
import 'package:machi_app/widgets/timeline/timeline_row.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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

  static const _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

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
    _pagingController.addPageRequestListener((pageKey) {
      _getUserBoard(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getUserBoard(int pageKey) async {
    try {
      List<Timeline> newItems =
          await _timelineApi.getTimelineByPageUserId(widget.user.userId);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
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
        if (widget.user.userStatus == "hidden") {
          return NoData(text: _i18n.translate("profile_nothing"));
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            _buttonDisplay(context)
                          ],
                        )
                      ],
                    ),
                  ),

                  /// Profile details
                  Container(
                    padding: const EdgeInsets.all(10.0),
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
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
        height: height * 0.7,
        width: width,
        child: PagedListView<int, dynamic>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<dynamic>(
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 500),
              itemBuilder: (context, item, index) {
                if ((index + 1) % 5 == 0) {
                  return Container(
                    height: itemHeight,
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        height: AD_HEIGHT,
                        width: width,
                        color: Theme.of(context).colorScheme.background,
                        child: const InlineAdaptiveAds(),
                      ),
                    ),
                  );
                }
                return TimelineRowWidget(item: item);
              }),
        ));
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
