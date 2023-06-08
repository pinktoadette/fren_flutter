import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

Widget textLinkPreview(BuildContext context, String text) {
  final urlRegExp = RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
  final urlMatches = urlRegExp.allMatches(text);
  List<String> urls = urlMatches
      .map((urlMatch) => text.substring(urlMatch.start, urlMatch.end))
      .toList();

  return SizedBox(
      child: Column(
    children: [
      Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      if (urls.isNotEmpty)
        AnyLinkPreview(
          displayDirection: UIDirection.uiDirectionHorizontal,
          link: urls[0],
          errorBody: 'Show my custom error body',
          errorTitle: 'Next one is youtube link, error title',
        ),
    ],
  ));
}
