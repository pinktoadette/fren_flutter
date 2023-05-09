import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/avatar_initials.dart';
import 'package:get/get.dart';

class TimelineHeader extends StatelessWidget {
  final _userApi = UserApi();
  final StoryUser user;
  final bool? showAvatar;
  final bool? showName;

  TimelineHeader({Key? key, required this.user, this.showAvatar, this.showName})
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
                    radius: 20,
                    photoUrl: user.photoUrl,
                    username: user.username),
              const SizedBox(width: 5),
              if (showName == true)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(user.username,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14))
                  ],
                )
            ]));
  }
}
