import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/user_api.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:get/get.dart';

class TimelineHeader extends StatelessWidget {
  final _userApi = UserApi();
  final StoryUser user;
  final bool? showAvatar;

  TimelineHeader({Key? key, required this.user, this.showAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          User u = await _userApi.getUserById(user.userId);
          Get.to(ProfileScreen(user: u));
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar == true)
                AvatarInitials(
                    radius: 10,
                    photoUrl: user.photoUrl,
                    username: user.username),
              const SizedBox(width: 5),
              Column(
                children: [
                  Text(
                    user.username,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ]));
  }
}
