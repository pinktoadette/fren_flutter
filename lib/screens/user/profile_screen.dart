import 'package:fren_app/api/dislikes_api.dart';
import 'package:fren_app/api/likes_api.dart';
import 'package:fren_app/api/matches_api.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/dialogs/its_match_dialog.dart';
import 'package:fren_app/dialogs/report_dialog.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/avatar_initials.dart';
import 'package:fren_app/widgets/button/circle_button.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scoped_model/scoped_model.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  /// Params
  final User user;
  final bool showButtons;
  final bool hideDislikeButton;
  final bool fromDislikesScreen;

  // Constructor
  const ProfileScreen(
      {Key? key,
      required this.user,
      this.showButtons = true,
      this.hideDislikeButton = false,
      this.fromDislikesScreen = false})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Local variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final LikesApi _likesApi = LikesApi();
  final DislikesApi _dislikesApi = DislikesApi();
  final MatchesApi _matchesApi = MatchesApi();
  late AppLocalizations _i18n;
  final double _iconSize = 16;

  @override
  void initState() {
    super.initState();
    // TODO: uncomment the line below if you want to display the Ads
    // Note: before make sure to add your Interstial AD ID
    // AppAdHelper().showInterstitialAd();
  }

  @override
  void dispose() {
    // TODO: uncomment the line below to dispose it.
    // AppAdHelper().disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          actions: <Widget>[
            // Check the current User ID
            if (UserModel().user.userId != widget.user.userId)
              IconButton(
                icon: Icon(Icons.flag,
                    color: Theme.of(context).primaryColor, size: 32),
                // Report/Block profile dialog
                onPressed: () =>
                    ReportDialog(userId: widget.user.userId).show(),
              )
          ],
        ),
        body: ScopedModelDescendant<UserModel>(
            builder: (context, child, userModel) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AvatarInitials(user: widget.user),
                        const SizedBox(width: 20),
                        Text(
                          widget.user.userFullname,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        /// Show verified badge
                        widget.user.userIsVerified
                            ? Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: Image.asset(
                                    'assets/images/verified_badge.png',
                                    width: 30,
                                    height: 30))
                            : const SizedBox(width: 0, height: 0),
                      ],
                    ),

                    /// Profile details
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Show VIP badge for current user
                              // UserModel().user.userId == widget.user.userId &&
                              //         UserModel().userIsVip
                              //     ? Container(
                              //         margin: const EdgeInsets.only(right: 5),
                              //         child: Image.asset(
                              //             'assets/images/crow_badge.png',
                              //             width: 25,
                              //             height: 25))
                              //     : const SizedBox(width: 0, height: 0),

                              ElevatedButton(
                                onPressed: () {},
                                child: const FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Icon(Iconsax.message)),
                              ),

                              /// Location distance
                              // CustomBadge(
                              //     icon: const Icon(Iconsax.location,
                              //         color: Colors.white),
                              //     text:
                              //         '${_appHelper.getDistanceBetweenUsers(userLat: widget.user.userGeoPoint.latitude, userLong: widget.user.userGeoPoint.longitude)}km')
                            ],
                          ),

                          const SizedBox(height: 5),

                          /// Home location
                          _rowProfileInfo(
                            context,
                            icon: Icon(Iconsax.location, size: _iconSize),
                            title: widget.user.userLocality != ''
                                ? "${widget.user.userLocality}, ${widget.user.userCountry}"
                                : "Location not set",
                          ),

                          const SizedBox(height: 5),

                          /// indsutry
                          _rowProfileInfo(context,
                              icon: Icon(Iconsax.briefcase, size: _iconSize),
                              title: widget.user.userIndustry),

                          const SizedBox(height: 5),

                          const Divider(),

                          /// Profile bio
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_i18n.translate("bio"),
                                style: Theme.of(context).textTheme.labelLarge),
                          ),
                          Text(widget.user.userBio ?? "",
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar:
            widget.showButtons ? _buildButtons(context) : null);
  }

  Widget _rowProfileInfo(BuildContext context,
      {required Widget icon, required String title}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  /// Build Like and Dislike buttons
  Widget _buildButtons(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            /// Dislike profile button
            if (!widget.hideDislikeButton)
              circleButton(
                  padding: 8.0,
                  icon:
                      Icon(Icons.close, color: Theme.of(context).primaryColor),
                  bgColor: Colors.grey,
                  onTap: () {
                    // Dislike profile
                    _dislikesApi.dislikeUser(
                        dislikedUserId: widget.user.userId,
                        onDislikeResult: (result) {
                          /// Check result to show message
                          if (!result) {
                            // Show error message
                            showScaffoldMessage(
                                context: context,
                                message: _i18n.translate(
                                    "you_already_disliked_this_profile"));
                          }
                        });
                  }),

            /// Like profile button
            circleButton(
                padding: 8.0,
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                bgColor: Theme.of(context).primaryColor,
                onTap: () {
                  // Like user
                  _likeUser(context);
                }),
          ],
        ));
  }

  /// Like user function
  Future<void> _likeUser(BuildContext context) async {
    /// Check match first
    _matchesApi
        .checkMatch(
            userId: widget.user.userId,
            onMatchResult: (result) {
              if (result) {
                /// Show It`s match dialog
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return ItsMatchDialog(
                        matchedUser: widget.user,
                        showSwipeButton: false,
                        swipeKey: null,
                      );
                    });
              }
            })
        .then((_) {
      /// Like user
      _likesApi.likeUser(
          likedUserId: widget.user.userId,
          userDeviceToken: widget.user.userDeviceToken,
          nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
              "${_i18n.translate("liked_your_profile_click_and_see")}",
          onLikeResult: (result) async {
            if (result) {
              // Show success message
              showScaffoldMessage(
                  context: context,
                  message:
                      '${_i18n.translate("like_sent_to")} ${widget.user.userFullname}');
            } else if (!result) {
              // Show error message
              showScaffoldMessage(
                  context: context,
                  message: _i18n.translate("you_already_liked_this_profile"));
            }

            /// Validate to delete disliked user from disliked list
            else if (result && widget.fromDislikesScreen) {
              // Delete in database
              await _dislikesApi.deleteDislikedUser(widget.user.userId);
            }
          });
    });
  }
}
