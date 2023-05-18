import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

/// Storyboard or story photoUrl cover
class StoryCover extends StatelessWidget {
  final String? photoUrl;
  final String title;
  final double? radius;
  const StoryCover(
      {Key? key, this.radius, required this.photoUrl, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: APP_ACCENT_COLOR,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(5, 15),
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(.6),
                  spreadRadius: -9)
            ]),
        child: SizedBox(
            height: 120,
            width: 100,
            child: (photoUrl == null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      photoUrl!,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Center(
                      child: Text(title.substring(0, 1).toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall),
                    ))));
  }
}
