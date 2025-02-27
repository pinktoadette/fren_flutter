import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/common/frosted_app_bar.dart';

/// Record voice, follows same class as types.Message
/// But will be stored as Voice
class PlaylistTab extends StatefulWidget {
  const PlaylistTab({Key? key}) : super(key: key);

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
        body: CustomScrollView(slivers: [
      FrostedAppBar(
          title: Text(
            i18n.translate("create_mix_playlist"),
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
