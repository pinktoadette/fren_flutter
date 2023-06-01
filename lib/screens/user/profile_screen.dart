import 'package:machi_app/api/machi/friend_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppLocalizations _i18n;
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
    Size size = MediaQuery.of(context).size;
    double avatar = 80;

    return Scaffold(
        body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          snap: false,
          floating: false,
          leading: const BackButton(),
          expandedHeight: 180.0,
          flexibleSpace: LayoutBuilder(builder: (context, constraints) {
            bool isAppBarExpanded = constraints.maxHeight >
                kToolbarHeight + MediaQuery.of(context).padding.top;

            return FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(
                  start: isAppBarExpanded ? 0.0 : 50.0,
                  bottom: 16.0,
                ),
                title: isAppBarExpanded
                    ? Row(children: [
                        Container(
                          width: avatar,
                          height: avatar,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8,
                                  offset: const Offset(5, 15),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer
                                      .withOpacity(.6),
                                  spreadRadius: -9)
                            ],
                          ),
                          child: AvatarInitials(
                            userId: widget.user.userId,
                            username: widget.user.username,
                            photoUrl: widget.user.userProfilePhoto,
                          ),
                        ),
                        Flexible(
                            child: SizedBox(
                                width: size.width - avatar,
                                height: 50,
                                child: Text(
                                  widget.user.username,
                                  overflow: TextOverflow.fade,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                )))
                      ])
                    : Text(
                        widget.user.username,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ));
          }),
        ),
        SliverToBoxAdapter(
            child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (UserModel().user.userStatus == "hidden")
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      width: size.width,
                      color: Colors.red,
                      child: Text(
                        _i18n.translate("profile_protected"),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Text("123 \n" + _i18n.translate("followers")),
                        const SizedBox(width: 50),
                        Text("431 \n" + _i18n.translate("following")),
                        const Spacer(),
                        _followButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Profile details
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Text(widget.user.userBio ?? "",
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),

                  _userPost()
                ],
              ),
            ),
          ],
        ))
      ],
    ));
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
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
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

  // Widget _friendRequest(BuildContext context) {
  //   _i18n = AppLocalizations.of(context);
  //   double width = MediaQuery.of(context).size.width;

  //   switch (friendStatus["status"]) {
  //     case 'REQUEST':
  //       if (friendStatus["isRequester"] == 1) {
  //         return OutlinedButton(
  //             onPressed: null,
  //             child: Text(
  //               _i18n.translate("friend_sent"),
  //               style: Theme.of(context).textTheme.labelSmall,
  //             ));
  //       }
  //       return Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(
  //                 width: width - 130,
  //                 child: Flexible(
  //                   fit: FlexFit.tight,
  //                   child: Text(_i18n.translate("friend_other_sent"),
  //                       style: Theme.of(context).textTheme.bodySmall),
  //                 ),
  //               ),
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   ElevatedButton(
  //                       onPressed: () {
  //                         _friendApi
  //                             .respondRequest(
  //                                 widget.user.userId, FriendStatus.active)
  //                             .then((_) => {_isUserFriend()});
  //                       },
  //                       child: Text(
  //                         _i18n.translate("friend_accept_request"),
  //                         style: const TextStyle(fontSize: 12),
  //                       )),
  //                   OutlinedButton(
  //                       onPressed: () {
  //                         _friendApi
  //                             .respondRequest(
  //                                 widget.user.userId, FriendStatus.unfriend)
  //                             .then((_) => {_isUserFriend()});
  //                       },
  //                       child: Text(
  //                         _i18n.translate("friend_reject_request"),
  //                         style: const TextStyle(fontSize: 12),
  //                       ),
  //                       style: OutlinedButton.styleFrom(
  //                           shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(50)))),
  //                 ],
  //               )
  //             ],
  //           )
  //         ],
  //       );
  //     case 'ACTIVE':
  //       return const SizedBox.shrink();
  //     case 'BLOCK':
  //       return const SizedBox.shrink();
  //     default:
  //       return OutlinedButton.icon(
  //         onPressed: () async {
  //           _friendApi
  //               .sendRequest(widget.user.userId)
  //               .then((_) => {_isUserFriend()});
  //         },
  //         icon: const Icon(Iconsax.message),
  //         label: Text(_i18n.translate("friend_send_request")),
  //       );
  //   }
  // }
}
