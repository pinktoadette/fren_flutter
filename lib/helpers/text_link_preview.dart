import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/decoration/text_border.dart';

Widget textLinkPreview(
    {required BuildContext context,
    required String text,
    TextAlign? textAlign = TextAlign.left,
    bool? useBorder = false,
    double? width,
    TextStyle? style}) {
  final urlRegExp = RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
  final urlMatches = urlRegExp.allMatches(text);
  List<String> urls = urlMatches
      .map((urlMatch) => text.substring(urlMatch.start, urlMatch.end))
      .toList();

  return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.center
            ? CrossAxisAlignment.center
            : textAlign == TextAlign.right
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          useBorder == true
              ? TextBorder(
                  text: urls.isNotEmpty ? text.replaceAll(urls[0], "") : text,
                  size: 16,
                  textAlign: textAlign,
                )
              : Text(
                  urls.isNotEmpty ? text.replaceAll(urls[0], "") : text,
                  textAlign: textAlign,
                  style: style ?? Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.fade,
                ),
          if (urls.isNotEmpty)
            AnyLinkPreview(
              showMultimedia: true,
              cache: const Duration(days: 3),
              displayDirection: UIDirection.uiDirectionHorizontal,
              link: urls[0],
              errorBody: 'Hmm... cant get link',
              errorTitle: 'Error title',
            ),
        ],
      ));
}
