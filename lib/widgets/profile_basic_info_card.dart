import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/user/edit_profile_screen.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:machi_app/widgets/common/default_card_border.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileBasicInfoCard extends StatelessWidget {
  const ProfileBasicInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    User user = UserModel().user;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ScrollPhysics(),
      child: Card(
        color: Theme.of(context).primaryColor,
        elevation: 4.0,
        shape: defaultCardBorder(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width - 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile image
              Row(
                children: [
                  AvatarInitials(
                    userId: user.userId,
                    username: user.username,
                    photoUrl: user.userProfilePhoto,
                  ),

                  const SizedBox(width: 10),

                  /// Profile details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.background),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                        icon: Icon(Iconsax.eye,
                            color: Theme.of(context).colorScheme.background),
                        label: Text(i18n.translate("view"),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.background,
                                fontSize: 12)),
                        onPressed: () {
                          /// Go to profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen(user: user)));
                        }),
                  ),
                  SizedBox(
                    height: 35,
                    child: TextButton.icon(
                        icon: Icon(Iconsax.edit,
                            color: Theme.of(context).colorScheme.background),
                        label: Text(i18n.translate("edit"),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.background,
                                fontSize: 12)),
                        onPressed: () {
                          /// Go to edit profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()));
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
