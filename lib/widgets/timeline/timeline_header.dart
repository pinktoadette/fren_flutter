import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/user_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:get/get.dart';

class TimelineHeader extends StatelessWidget {
  final bool? showAvatar = false;
  final _userApi = UserApi();

  final String userId;
  final String photoUrl;
  final String username;

  TimelineHeader(
      {Key? key,
      required this.userId,
      required this.photoUrl,
      required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          User user = await _userApi.getUserById(userId);
          Get.to(ProfileScreen(user: user));
        },
        child: Row(children: [
          if (showAvatar == true)
            AvatarInitials(radius: 20, photoUrl: photoUrl, username: username),
          Text("@$username")
        ]));
  }
}
