import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/user_api.dart';
import 'package:machi_app/constants/constants.dart';
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

class TimelineHeader extends StatefulWidget {
  final StoryUser user;
  final double? radius;
  final double? paddingLeft;
  final int? timestamp;
  final bool? showAvatar;
  final bool? showName;
  final bool? showMenu;
  final bool? isChild;
  final double? fontSize;
  final Widget? underNameRow;
  final StoryComment? comment;
  final Function(String action)? onDeleteComment;

  const TimelineHeader({
    Key? key,
    required this.user,
    this.showAvatar = true,
    this.radius = 10,
    this.timestamp,
    this.paddingLeft,
    this.showMenu,
    this.showName,
    this.underNameRow,
    this.comment,
    this.fontSize,
    this.isChild = false,
    this.onDeleteComment,
  }) : super(key: key);

  @override
  State<TimelineHeader> createState() => _TimelineHeaderState();
}

class _TimelineHeaderState extends State<TimelineHeader> {
  final _userApi = UserApi();
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    AppLocalizations i18n = AppLocalizations.of(context);
    return InkWell(
        onTap: () async {
          User u = await _userApi.getUserById(
              userId: widget.user.userId, cancelToken: _cancelToken);
          Get.to(() => ProfileScreen(user: u));
        },
        child: Container(
          width: width,
          padding: EdgeInsets.only(left: widget.paddingLeft ?? 15, right: 15),
          child: Row(children: [
            if (widget.showAvatar == true)
              AvatarInitials(
                  radius: widget.radius,
                  photoUrl: widget.user.photoUrl,
                  username: widget.user.username),
            const SizedBox(width: 5),
            if (widget.showName == true)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: widget.isChild == true
                                ? width - 150
                                : width - 120,
                            child: Text(widget.user.username,
                                style:
                                    TextStyle(fontSize: widget.fontSize ?? 16)),
                          ),
                          if (widget.timestamp != null)
                            Text(formatDate(widget.timestamp!),
                                style: const TextStyle(fontSize: 10)),
                          if (widget.underNameRow != null) widget.underNameRow!
                        ],
                      ),
                      if (widget.showMenu == true)
                        PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              size: 14,
                            ),
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem(
                                    value: 'report_user',
                                    child: Text(
                                      i18n.translate("report_user"),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  if (widget.comment != null)
                                    PopupMenuItem(
                                      value: 'report_comment',
                                      child: Text(
                                          i18n.translate("report_comment"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                  if ((widget.user.userId ==
                                      UserModel().user.userId))
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(i18n.translate("DELETE"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                ],
                            onSelected: (val) {
                              switch (val) {
                                case 'delete':
                                  widget.onDeleteComment!(val);
                                  break;
                                case 'report_user':
                                  _onReport(
                                      context, 'user', widget.user.userId);
                                  break;
                                case 'report_comment':
                                  _onReport(context, 'comment',
                                      widget.comment!.commentId!);
                                  break;
                                default:
                                  break;
                              }
                            })
                    ],
                  ),
                ],
              )
          ]),
        ));
  }

  void _onReport(BuildContext context, String itemType, String itemId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
            child: ReportForm(
              itemId: itemId,
              itemType: itemType,
            ));
      },
    );
  }
}
