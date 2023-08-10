import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:machi_app/api/machi/friend_api.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/user/follower_list.dart';
import 'package:machi_app/screens/user/following_list.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/profile/gallery/gallery_mini.dart';
import 'package:machi_app/widgets/profile/user_gallery.dart';
import 'package:machi_app/widgets/profile/user_story.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppLocalizations _i18n;
  final _userApi = UserApi();
  final _friendApi = FriendApi();
  ChatController chatController = Get.find(tag: 'chatroom');

  List<Storyboard> boards = [];
  bool following = false;
  int followings = 0;
  int followers = 0;

  @override
  void initState() {
    _isUserFriend();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _isUserFriend() async {
    if (!mounted) {
      return;
    }
    final user = await _userApi.getUserById(widget.user.userId);
    _setUserCount(user);
  }

  void _setUserCount(User user) {
    setState(() {
      following = user.following ?? false;
      followings = user.followings ?? 0;
      followers = user.followers ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    double avatar = 80;

    return Scaffold(
        body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          snap: false,
          floating: false,
          centerTitle: false,
          leading: const BackButton(),
          expandedHeight: 180.0,
          flexibleSpace: LayoutBuilder(builder: (context, constraints) {
            bool isAppBarExpanded = constraints.maxHeight >
                kToolbarHeight + MediaQuery.of(context).padding.top;

            return FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(
                  start: isAppBarExpanded ? 0.0 : 50.0,
                  bottom: 16.0,
                ),
                title: isAppBarExpanded
                    ? Row(children: [
                        Container(
                          width: avatar,
                          height: avatar,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8,
                                  offset: const Offset(5, 15),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer
                                      .withOpacity(.6),
                                  spreadRadius: -9)
                            ],
                          ),
                          child: AvatarInitials(
                            userId: widget.user.userId,
                            username: widget.user.username,
                            photoUrl: widget.user.userProfilePhoto,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                            child: SizedBox(
                                width: size.width - avatar,
                                height: 50,
                                child: Semantics(
                                    label: widget.user.username,
                                    child: Text(
                                      widget.user.username,
                                      overflow: TextOverflow.fade,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                    ))))
                      ])
                    : Semantics(
                        label: widget.user.username,
                        child: Text(
                          widget.user.username,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )));
          }),
        ),
        SliverToBoxAdapter(
            child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((UserModel().user.userStatus == "hidden") &
                      (widget.user.userId == UserModel().user.userId))
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      width: size.width,
                      color: APP_WARNING,
                      child: Text(
                        _i18n.translate("profile_protected"),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Semantics(
                            label: 'followers',
                            button: true,
                            child: TextButton(
                              onPressed: () {
                                Get.to(() => FollowerList(user: widget.user));
                              },
                              child: Text(
                                  "$followers \n" +
                                      _i18n.translate("followers"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall),
                            )),
                        const SizedBox(width: 20),
                        Semantics(
                            label: 'following',
                            button: true,
                            child: TextButton(
                              onPressed: () {
                                Get.to(() => FollowingList(user: widget.user));
                              },
                              child: Text(
                                  "$followings \n" +
                                      _i18n.translate("following"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall),
                            )),
                        const Spacer(),
                        _followButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Profile details
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Text(
                        widget.user.userBio!.isEmpty
                            ? "Hey there 👋"
                            : widget.user.userBio!,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  ..._postImagesBots(size),
                  SizedBox(
                      width: size.width,
                      child: UserStory(userId: widget.user.userId))
                ],
              ),
            ),
          ],
        ))
      ],
    ));
  }

  List<Widget> _postImagesBots(Size size) {
    if ((widget.user.userStatus == "hidden") &
        (widget.user.userId != UserModel().user.userId)) {
      return [NoData(text: _i18n.translate("profile_protected_view"))];
    }
    return [..._userGallery(size)];
  }

  List<Widget> _userGallery(Size size) {
    return [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _i18n.translate("gallery"),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              TextButton(
                child: Text(_i18n.translate("see_all"),
                    style: Theme.of(context).textTheme.labelSmall),
                onPressed: () {
                  Get.to(() => UserGallery(userId: widget.user.userId));
                },
              ),
            ],
          )),
      GalleryWidget(userId: widget.user.userId),
    ];
  }

  Widget _followButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor:
                following == true ? Colors.white : APP_ACCENT_COLOR),
        onPressed: () async {
          try {
            User user = await _friendApi.followRequest(widget.user.userId);
            _setUserCount(user);
          } catch (err, s) {
            Get.snackbar(_i18n.translate("error"),
                _i18n.translate("an_error_has_occurred"),
                snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);

            await FirebaseCrashlytics.instance.recordError(err, s,
                reason: 'Error following user', fatal: true);
          }
        },
        child: following == true
            ? Text(_i18n.translate("following"))
            : Text(_i18n.translate("follow")));
  }
}
