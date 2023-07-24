import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ignore: constant_identifier_names
enum PageDirection { HORIZONTAL, VERTICAL }

class PageScrollDirection extends StatelessWidget {
  final PageDirection? selection;
  final Function(PageDirection direction) onSelection;
  const PageScrollDirection({
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
                      i18n.translate("story_page_direction"),
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
              _createRow(
                  context,
                  const Icon(Icons.align_horizontal_right_rounded),
                  i18n.translate("story_page_horizontal"),
                  PageDirection.HORIZONTAL),
              _createRow(
                  context,
                  const Icon(Icons.align_vertical_bottom_rounded),
                  i18n.translate("story_page_vertical"),
                  PageDirection.VERTICAL),
            ]));
  }

  Widget _createRow(
      BuildContext context, Icon icon, String item, PageDirection direction) {
    return SizedBox(
        width: double.infinity,
        child: InkWell(
            onTap: () async {
              onSelection(direction);
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
                  Text(item,
                      style: TextStyle(
                          fontSize: 16,
                          color: selection == direction
                              ? APP_ACCENT_COLOR
                              : APP_INVERSE_PRIMARY_COLOR))
                ],
              ),
            )));
  }
}
