import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum Layout { PUBLICATION, CONVO, FLASHCARD }

class StoryLayout extends StatelessWidget {
  final Function(Layout) onSelection;
  const StoryLayout({
    Key? key,
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
            ]));
  }

  Widget _createRow(
      BuildContext context, Icon icon, String item, Layout layout) {
    return SizedBox(
        width: double.infinity,
        child: InkWell(
            onTap: () async {
              onSelection(layout);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  icon,
                  const SizedBox(
                    width: 10,
                  ),
                  Text(item, style: const TextStyle(fontSize: 16))
                ],
              ),
            )));
  }
}
