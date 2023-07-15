import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/chat/typing_indicator.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';

class CustomHeaderInputWidget extends StatefulWidget {
  final Function(dynamic data) onUpdateWidget;
  final Function(String image) onImageSelect;

  final String? onTagChange;
  final bool? isBotTyping;
  final bool? showFastForward;
  final types.PartialImage? attachmentPreview;
  const CustomHeaderInputWidget(
      {super.key,
      required this.onUpdateWidget,
      required this.onImageSelect,
      this.onTagChange,
      this.isBotTyping,
      this.showFastForward,
      this.attachmentPreview});

  @override
  _CustomHeaderInputWidgetState createState() =>
      _CustomHeaderInputWidgetState();
}

class _CustomHeaderInputWidgetState extends State<CustomHeaderInputWidget> {
  String? _selectedIcon;
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (_selectedIcon != null && widget.onTagChange == null) {
      setState(() {
        _selectedIcon = widget.onTagChange;
      });
    }
    super.didUpdateWidget(oldWidget);
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
                if (subscribeController.credits.value == 0) {
                  _showSubscription(context);
                } else {
                  widget.onImageSelect(SLASH_IMAGINE);
                  _setStateColor('imagine');
                }
              },
              icon: Icon(
                Iconsax.image,
                size: 14,
                color: _selectedIconColor("imagine"),
              )),
          IconButton(
              onPressed: () {
                if (subscribeController.credits.value == 0) {
                  _showSubscription(context);
                } else {
                  widget.onImageSelect(SLASH_REIMAGINE);
                  _setStateColor('reimagine');
                }
              },
              icon: Icon(Iconsax.brush_4,
                  size: 14, color: _selectedIconColor("reimagine"))),
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
                    borderRadius: BorderRadius.circular(25), // Image border
                    child: SizedBox.fromSize(
                        size: const Size.fromRadius(40), // Image radius
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
              child: const Icon(
                Iconsax.close_circle,
                size: 18,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showSubscription(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const FractionallySizedBox(
            heightFactor: 0.95, child: SubscriptionProduct()));
  }
}
