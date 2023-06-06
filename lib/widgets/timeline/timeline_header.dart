import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/report_list.dart';

class TimelineHeader extends StatelessWidget {
  final _userApi = UserApi();
  final StoryUser user;
  final double? radius;
  final int? timestamp;
  final bool? showAvatar;
  final bool? showName;
  final bool? showMenu;
  final StoryComment? comment;
  final Function(String action)? onDeleteComment;

  TimelineHeader(
      {Key? key,
      required this.user,
      this.showAvatar = true,
      this.radius = 10,
      this.timestamp,
      this.showMenu,
      this.showName,
      this.comment,
      this.onDeleteComment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    AppLocalizations _i18n = AppLocalizations.of(context);
    return InkWell(
        onTap: () async {
          User u = await _userApi.getUserById(user.userId);
          Get.to(ProfileScreen(user: u));
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showAvatar == true)
                AvatarInitials(
                    radius: radius,
                    photoUrl: user.photoUrl,
                    username: user.username),
              const SizedBox(width: 5),
              if (showName == true)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: width - 117,
                          child: Text(user.username,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        if (showMenu == true)
                          PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 16,
                              ),
                              itemBuilder: (context) =>
                                  <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      child:
                                          Text(_i18n.translate("report_user")),
                                      value: 'report_user',
                                    ),
                                    if (comment != null)
                                      PopupMenuItem(
                                        child: Text(
                                            _i18n.translate("report_comment")),
                                        value: 'report_comment',
                                      ),
                                    if ((user.userId ==
                                        UserModel().user.userId))
                                      PopupMenuItem(
                                        child: Text(_i18n.translate("DELETE")),
                                        value: 'delete',
                                      ),
                                  ],
                              onSelected: (val) {
                                switch (val) {
                                  case 'delete':
                                    onDeleteComment!(val);
                                    break;
                                  case 'report_user':
                                    _onReport(context, 'user', user.userId);
                                    break;
                                  case 'report_comment':
                                    _onReport(context, 'comment',
                                        comment!.commentId!);
                                    break;
                                  default:
                                    break;
                                }
                              })
                      ],
                    ),
                    if (timestamp != null)
                      Text(formatDate(timestamp!),
                          style: Theme.of(context).textTheme.labelSmall),
                  ],
                )
            ]));
  }

  void _onReport(BuildContext context, String itemType, String itemId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.9,
            child: ReportForm(
              itemId: itemId,
              itemType: itemType,
            ));
      },
    );
  }
}
