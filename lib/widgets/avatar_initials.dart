import 'package:flutter/material.dart';
import 'package:fren_app/datas/user.dart';

class AvatarInitials extends StatelessWidget {
  final User user;
  final double? radius;
  const AvatarInitials({Key? key, required this.user, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration:
          const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: radius ?? 50,
        child: (user.userProfilePhoto == '')
            ? Center(
                child: Text(user.userFullname.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall),
              )
            : null,
        foregroundImage: user.userProfilePhoto == ''
            ? null
            : NetworkImage(user.userProfilePhoto),
        backgroundColor: Colors.white,
      ),
    );
  }
}
