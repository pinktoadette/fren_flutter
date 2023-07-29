import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/widgets/subscribe/subscribe_how_to_art_info.dart';

class SubscribeHowToArt extends StatefulWidget {
  const SubscribeHowToArt({Key? key}) : super(key: key);

  @override
  _SubscribeHowToArtState createState() => _SubscribeHowToArtState();
}

class _SubscribeHowToArtState extends State<SubscribeHowToArt> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          _showHowTo(context);
        },
        icon: const Icon(Iconsax.brush_4));
  }

  void _showHowTo(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const FractionallySizedBox(
            heightFactor: MODAL_HEIGHT_SMALL_FACTOR,
            child: SubscribeHowToInfo()));
  }
}
