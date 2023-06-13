import 'dart:io';

import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/chat/typing_indicator.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:iconsax/iconsax.dart';

class CustomHeaderInputWidget extends StatefulWidget {
  final Function(dynamic data) onUpdateWidget;
  final Function(String image) onImageSelect;

  final bool? isBotTyping;
  final types.PartialImage? attachmentPreview;
  const CustomHeaderInputWidget(
      {super.key,
      required this.onUpdateWidget,
      required this.onImageSelect,
      this.isBotTyping,
      this.attachmentPreview});

  @override
  _CustomHeaderInputWidgetState createState() =>
      _CustomHeaderInputWidgetState();
}

class _CustomHeaderInputWidgetState extends State<CustomHeaderInputWidget> {
  String? _selectedIcon;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    return Column(children: [
      _showHeader(context),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                widget.onImageSelect('#imagine');
                _setStateColor('imagine');
              },
              icon: Icon(
                Iconsax.image,
                size: 14,
                color: _selectedIconColor("imagine"),
              )),
          IconButton(
              onPressed: () {
                widget.onImageSelect('#reimagine');
                _setStateColor('reimagine');
              },
              icon: Icon(Icons.lightbulb_outlined,
                  size: 14, color: _selectedIconColor("reimagine"))),
          IconButton(
              onPressed: () {
                widget.onImageSelect('#board');
                _setStateColor('board');
              },
              icon: Icon(Iconsax.book,
                  size: 14, color: _selectedIconColor("board"))),
          const Spacer(),
          _displayHint(_i18n),
        ],
      )
    ]);
  }

  Widget _displayHint(AppLocalizations _i18n) {
    switch (_selectedIcon) {
      case "imagine":
        return Text(
          _i18n.translate("story_header_you_create"),
          style: const TextStyle(fontSize: 12),
        );
      case "reimagine":
        return Text(
          _i18n.translate("story_header_I_create"),
          style: const TextStyle(fontSize: 12),
        );
      case "board":
        return Text(
          _i18n.translate("story_header_auto_add_responses_to_board"),
          style: const TextStyle(fontSize: 12),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _setStateColor(String item) {
    setState(() {
      _selectedIcon = _selectedIcon == item ? null : item;
    });
  }

  Color _selectedIconColor(String item) {
    if (_selectedIcon == item) {
      return APP_ACCENT_COLOR;
    } else {
      return APP_PRIMARY_BACKGROUND;
    }
  }

  Widget _showHeader(BuildContext context) {
    if (widget.isBotTyping == true) {
      return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: JumpingDots(color: Theme.of(context).colorScheme.primary),
          ));
    } else if (widget.attachmentPreview?.uri != null) {
      return Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                height: 80,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Image border
                    child: SizedBox.fromSize(
                        size: const Size.fromRadius(48), // Image radius
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: Image.file(
                            File(widget.attachmentPreview!.uri),
                            fit: BoxFit.fitHeight,
                            width: 80,
                            height: 80,
                          ),
                        ))),
              )),
          Positioned(
            top: 0,
            right: 5,
            child: GestureDetector(
              onTap: () {
                widget.onUpdateWidget({'image': null});
              },
              child: const Icon(Iconsax.close_circle),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
