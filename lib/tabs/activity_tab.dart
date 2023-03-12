import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:fren_app/widgets/bot/quick_chat.dart';
import 'package:fren_app/widgets/bot/new_bots.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/discover_card.dart';
import 'package:fren_app/widgets/search.dart';
import 'package:fren_app/widgets/widget_title.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  _ActivityTabState createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  // Variables
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  List<DocumentSnapshot<Map<String, dynamic>>>? _users;
  late AppLocalizations _i18n;
  final _listFeatures = [

  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    // return _showUsers();
    return Scaffold(
      body: Column(
        children:  [


          // Container(
          // margin: const EdgeInsets.symmetric(vertical: 5.0),
          // height: 350.0,
          // child: ListView.builder(
          //   shrinkWrap: true,
          //   scrollDirection: Axis.horizontal,
          //   itemCount: _listFeatures!.length,
          //   itemBuilder: (context, index) => DiscoverCard()
          // ),
          // ),
          SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: Column(
                children: [
                  WidgetTitle(title:_i18n.translate("activity")),
                  // ActivityWidget()
                  DiscoverCard()
                ],
              ),
          ),

          const Spacer(),

          const QuickChat(),

        ]
      )
    );
  }



}
