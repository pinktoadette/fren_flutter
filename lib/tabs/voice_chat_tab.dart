import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';

/// Record voice, follows same class as types.Message
/// But will be stored as Voice
class VoiceRecordTab extends StatefulWidget {
  const VoiceRecordTab({Key? key}) : super(key: key);

  @override
  _VoiceRecordState createState() => _VoiceRecordState();
}

class _VoiceRecordState extends State<VoiceRecordTab> {
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Sound recording"),
    );
  }
}
