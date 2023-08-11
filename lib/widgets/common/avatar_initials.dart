import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:get/get.dart';

class AvatarInitials extends StatefulWidget {
  final String? userId;
  final String photoUrl;
  final String username;
  final double? radius;

  const AvatarInitials({
    Key? key,
    this.radius,
    this.userId,
    required this.photoUrl,
    required this.username,
  }) : super(key: key);

  @override
  State<AvatarInitials> createState() => _AvatarInitialsState();
}

class _AvatarInitialsState extends State<AvatarInitials> {
  final _userApi = UserApi();
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.radius != null && widget.userId != null) {
          User user = await _userApi.getUserById(
              userId: widget.userId!, cancelToken: _cancelToken);
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
          radius: widget.radius ?? 50,
          foregroundImage:
              widget.photoUrl == '' ? null : ImageCacheWrapper(widget.photoUrl),
          backgroundColor: APP_INVERSE_PRIMARY_COLOR,
          child: (widget.photoUrl == '')
              ? Center(
                  child: Text(widget.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: APP_PRIMARY_COLOR, fontSize: 18)),
                )
              : null,
        ),
      ),
    );
  }
}
