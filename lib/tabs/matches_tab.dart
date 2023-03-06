import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/matches_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/chat_screen.dart';
import 'package:fren_app/widgets/build_title.dart';
import 'package:fren_app/widgets/loading_card.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/profile_card.dart';
import 'package:fren_app/widgets/users_grid.dart';
import 'package:flutter/material.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({Key? key}) : super(key: key);

  @override
  _MatchesTabState createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  /// Variables
  final MatchesApi _matchesApi = MatchesApi();
  List<DocumentSnapshot<Map<String, dynamic>>>? _matches;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();

    /// Get user matches
    _matchesApi.getMatches().then((matches) {
      if (mounted) setState(() => _matches = matches);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Column(
      children: [
        /// Header
        BuildTitle(
          title: _i18n.translate("requests"),
        ),

        /// Show matches
        Expanded(child: _showMatches()),
      ],
    );
  }

  /// Handle matches result
  Widget _showMatches() {
    /// Check result
    if (_matches == null) {
      return Processing(text: _i18n.translate("loading"));
    } else if (_matches!.isEmpty) {
      /// No match
      return NoData( text: _i18n.translate("no_match"));
    } else {
      /// Load matches
      return UsersGrid(
        itemCount: _matches!.length,
        itemBuilder: (context, index) {
          /// Get match doc
          final DocumentSnapshot<Map<String, dynamic>> match = _matches![index];

          /// Load profile
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: UserModel().getUser(match.id),
              builder: (context, snapshot) {
                /// Check result
                if (!snapshot.hasData) return const LoadingCard();

                /// Get user object
                final User user = User.fromDocument(snapshot.data!.data()!);

                /// Show user card
                return GestureDetector(
                    child: ProfileCard(user: user, page: 'matches'),
                    onTap: () {
                      /// Go to chat screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(user: user)));
                    });
              });
        },
      );
    }
  }
}
