import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/user_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:get/get.dart';

class AvatarInitials extends StatelessWidget {
  final _userApi = UserApi();
  final String? userId;
  final String photoUrl;
  final String username;
  final double? radius;
  AvatarInitials(
      {Key? key,
      this.radius,
      this.userId,
      required this.photoUrl,
      required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (userId != null) {
          User user = await _userApi.getUserById(userId!);
          Get.to(ProfileScreen(user: user));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle),
        child: CircleAvatar(
          radius: radius ?? 30,
          child: (photoUrl == '')
              ? Center(
                  child: Text(username.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall),
                )
              : null,
          foregroundImage: photoUrl == '' ? null : NetworkImage(photoUrl),
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }
}
