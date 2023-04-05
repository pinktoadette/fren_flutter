import 'package:flutter/material.dart';

class AvatarInitials extends StatelessWidget {
  final String photoUrl;
  final String username;
  final double? radius;
  const AvatarInitials(
      {Key? key, this.radius, required this.photoUrl, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration:
          const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: radius ?? 30,
        child: (photoUrl == '')
            ? Center(
                child: Text(username.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall),
              )
            : null,
        foregroundImage: photoUrl == '' ? null : NetworkImage(photoUrl),
        backgroundColor: Colors.white,
      ),
    );
  }
}
