import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/common/frosted_app_bar.dart';

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
    final _i18n = AppLocalizations.of(context);
    return Scaffold(
        body: CustomScrollView(slivers: [
      FrostedAppBar(
          title: Text(
            _i18n.translate("storyboard_playlist"),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: const [],
          showLeading: true),
      const SliverToBoxAdapter(
          child: Center(
        child: Text("Sound recording"),
      ))
    ]));
  }
}
