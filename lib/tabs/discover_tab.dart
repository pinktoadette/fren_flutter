import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/dislikes_api.dart';
import 'package:fren_app/api/likes_api.dart';
import 'package:fren_app/api/matches_api.dart';
import 'package:fren_app/api/visits_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/dialogs/its_match_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:fren_app/screens/disliked_profile_screen.dart';
import 'package:fren_app/screens/profile_screen.dart';
import 'package:fren_app/widgets/bot/quick_chat.dart';
import 'package:fren_app/widgets/button/circle_button.dart';
import 'package:fren_app/widgets/bot/new_bots.dart';
import 'package:fren_app/widgets/no_data.dart';
import 'package:fren_app/widgets/processing.dart';
import 'package:fren_app/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/api/users_api.dart';
import 'package:fren_app/widgets/search.dart';
import 'package:fren_app/widgets/activity.dart';
import 'package:fren_app/widgets/widget_title.dart';
import 'package:iconsax/iconsax.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({Key? key}) : super(key: key);

  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  // Variables
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  final LikesApi _likesApi = LikesApi();
  final DislikesApi _dislikesApi = DislikesApi();
  final MatchesApi _matchesApi = MatchesApi();
  final VisitsApi _visitsApi = VisitsApi();
  final UsersApi _usersApi = UsersApi();
  List<DocumentSnapshot<Map<String, dynamic>>>? _users;
  late AppLocalizations _i18n;

  /// Get all Users
  Future<void> _loadUsers(
      List<DocumentSnapshot<Map<String, dynamic>>> dislikedUsers) async {
    _usersApi.getUsers(dislikedUsers: dislikedUsers).then((users) {
      // Check result
      if (users.isNotEmpty) {
        if (mounted) {
          setState(() => _users = users);
        }
      } else {
        if (mounted) {
          setState(() => _users = []);
        }
      }
      // Debug
      debugPrint('getUsers() -> ${users.length}');
      debugPrint('getDislikedUsers() -> ${dislikedUsers.length}');
    });
  }

  @override
  void initState() {
    super.initState();

    /// First: Load All Disliked Users to be filtered
    _dislikesApi.getDislikedUsers(withLimit: false).then(
        (List<DocumentSnapshot<Map<String, dynamic>>> dislikedUsers) async {
      /// Validate user max distance
      await UserModel().checkUserMaxDistance();

      /// Load all users
      await _loadUsers(dislikedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    // return _showUsers();
    return Scaffold(
      body: Column(
        children:  [

          const SearchBar(),
          WidgetTitle(title: "${_i18n.translate("my")} machi"),
          const ListBotWidget(),

          SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: Column(
                children: [
                  WidgetTitle(title:_i18n.translate("activity")),
                  // ActivityWidget()
                ],
              ),
          ),

          const Spacer(),

          QuickChat(),

        ]
      )
    );
  }



}
