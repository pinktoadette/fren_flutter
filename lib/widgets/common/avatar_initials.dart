import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
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
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius ?? 50,
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
