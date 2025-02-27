import 'package:dio/dio.dart';
import 'package:machi_app/api/machi/friend_api.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowingList extends StatefulWidget {
  final User user;

  const FollowingList({Key? key, required this.user}) : super(key: key);

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  late AppLocalizations _i18n;
  final _userApi = UserApi();
  final _friendApi = FriendApi();
  final _cancelToken = CancelToken();
  ChatController chatController = Get.find(tag: 'chatroom');

  List<User> followers = [];

  @override
  void initState() {
    _getFollowers();
    super.initState();
  }

  void _getFollowers() async {
    if (!mounted) {
      return;
    }
    final user = await _friendApi.userFollowing(widget.user.userId);

    setState(() {
      followers = user;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(_i18n.translate("following")),
        ),
        body: ListView.builder(
            itemCount: followers.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                dense: true,
                isThreeLine: true,
                leading: AvatarInitials(
                    radius: 30,
                    photoUrl: followers[index].userProfilePhoto,
                    username: followers[index].username),
                title: Text(
                  followers[index].username,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(followers[index].userBio ?? "Hey there 👋"),
                  ],
                ),
                onTap: () async {
                  User u = await _userApi.getUserById(
                      userId: followers[index].userId,
                      cancelToken: _cancelToken);
                  Get.to(() => ProfileScreen(user: u));
                },
              );
            }));
  }
}
