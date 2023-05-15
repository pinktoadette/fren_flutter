import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';

/// Record voice, follows same class as types.Message
/// But will be stored as Voice
class PlaylistTab extends StatefulWidget {
  const PlaylistTab({Key? key}) : super(key: key);

  @override
  _PlaylistTabState createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Sound recording"),
    );
  }
}
