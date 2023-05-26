import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:get/get.dart';

class TimelineHeader extends StatelessWidget {
  final _userApi = UserApi();
  final StoryUser user;
  final double? radius;
  final int? timestamp;
  final bool? showAvatar;
  final bool? showName;

  TimelineHeader(
      {Key? key,
      required this.user,
      this.showAvatar = true,
      this.radius = 10,
      this.timestamp,
      this.showName})
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showAvatar == true)
                AvatarInitials(
                    radius: radius,
                    photoUrl: user.photoUrl,
                    username: user.username),
              const SizedBox(width: 5),
              if (showName == true)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium),
                    if (timestamp != null)
                      Text(formatDate(timestamp!),
                          style: Theme.of(context).textTheme.labelSmall),
                  ],
                )
            ]));
  }
}
