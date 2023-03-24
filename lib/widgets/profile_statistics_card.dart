import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/profile_likes_screen.dart';
import 'package:fren_app/screens/user/profile_visits_screen.dart';
import 'package:fren_app/widgets/default_card_border.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileStatisticsCard extends StatelessWidget {
  // Text style
  final _textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  const ProfileStatisticsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);

    return Card(
      elevation: 4.0,
      color: Colors.grey[100],
      shape: defaultCardBorder(),
      child: Column(
        children: [
          ListTile(
            leading:
                Icon(Iconsax.message, color: Theme.of(context).primaryColor),
            title: Text(i18n.translate("LIKES"), style: _textStyle),
            trailing: _counter(context, UserModel().user.userTotalLikes),
            onTap: () {
              /// Go to profile likes screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProfileLikesScreen()));
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(Iconsax.eye, color: Theme.of(context).primaryColor),
            title: Text(i18n.translate("VISITS"), style: _textStyle),
            trailing: _counter(context, UserModel().user.userTotalVisits),
            onTap: () {
              /// Go to profile visits screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProfileVisitsScreen()));
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(Iconsax.close_circle,
                color: Theme.of(context).primaryColor),
            title: Text(i18n.translate("DISLIKED_PROFILES"), style: _textStyle),
            trailing: _counter(context, UserModel().user.userTotalDisliked),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _counter(BuildContext context, int value) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor, //.withAlpha(85),
            shape: BoxShape.circle),
        padding: const EdgeInsets.all(6.0),
        child: Text(value.toString(),
            style: const TextStyle(color: Colors.white)));
  }
}
