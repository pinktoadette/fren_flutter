import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ignore: constant_identifier_names
enum Layout { PUBLICATION, CONVO, FLASHCARD, COMIC }

class StoryLayout extends StatelessWidget {
  final Layout? selection;
  final Function(Layout) onSelection;
  const StoryLayout({
    Key? key,
    this.selection,
    required this.onSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      i18n.translate("story_layout"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.grid_3))
                ],
              ),
              const Divider(height: 5, thickness: 1),
              _createRow(context, const Icon(Iconsax.book),
                  i18n.translate("story_layout_plaintext"), Layout.PUBLICATION),
              _createRow(context, const Icon(Iconsax.messages_1),
                  i18n.translate("story_layout_conversation"), Layout.CONVO),
              _createRow(context, const Icon(Iconsax.smileys),
                  i18n.translate("story_layout_comic"), Layout.COMIC),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  Text(i18n.translate("story_layout_comic_note"),
                      style:
                          const TextStyle(fontSize: 12, color: APP_MUTED_COLOR))
                ],
              )
            ]));
  }

  Widget _createRow(
      BuildContext context, Icon icon, String item, Layout layout) {
    return SizedBox(
        width: double.infinity,
        child: InkWell(
            onTap: () async {
              onSelection(layout);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  icon,
                  const SizedBox(
                    width: 10,
                  ),
                  Text(item,
                      style: TextStyle(
                          fontSize: 16,
                          color: selection == layout
                              ? APP_ACCENT_COLOR
                              : APP_INVERSE_PRIMARY_COLOR))
                ],
              ),
            )));
  }
}
