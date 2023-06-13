import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:get/get.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';

StoryComment initial = StoryComment(
  comment: '',
  createdAt: getDateTimeEpoch(),
  updatedAt: getDateTimeEpoch(),
  user: StoryUser(
      userId: UserModel().user.userId,
      photoUrl: UserModel().user.userProfilePhoto,
      username: UserModel().user.username),
);

/// tracks replies to who
/// listens for list of comment widget for pagination
class CommentController extends GetxController {
  static const int _pageSize = ALL_PAGE_SIZE;
  final _commentApi = CommentApi();

  final PagingController<int, dynamic> pagingController =
      PagingController(firstPageKey: 0);

  RxList<StoryComment> comments = <StoryComment>[].obs;
  // ignore: prefer_final_fields
  // can't make it null!. idk
  final Rx<StoryComment> _replyToComment = initial.obs;

  // sets who the user is posting comment to.
  StoryComment get replyToComment => _replyToComment.value;
  set replyToComment(StoryComment value) => _replyToComment.value = value;

  @override
  void onInit() {
    super.onInit();
    pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  // sets which comment the user is replying to.
  void replyTo(StoryComment comment) {
    _replyToComment.value = comment;
  }

  // clears out reply to in post comment.
  // will not take null. idk?
  void clearReplyTo() {
    _replyToComment.value = initial;
  }

  Future<void> _fetchPage(int pageKey) async {
    StoryboardController storyboardController = Get.find(tag: "storyboard");

    try {
      List<StoryComment> newItems = await _commentApi.getComments(
          pageKey, _pageSize, storyboardController.currentStory.storyId);

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  void addItem(StoryComment comment) async {
    if (comment.commentId != null) {
      pagingController.appendLastPage([comment]);
      pagingController.refresh();
    }
  }

  void updateItem(StoryComment comment) async {
    pagingController.itemList!
        .removeWhere((element) => element.commentId == comment.commentId);
    pagingController.refresh();
  }

  void removeItem(StoryComment comment) async {
    pagingController.itemList!
        .removeWhere((element) => element.commentId == comment.commentId);
    pagingController.refresh();
  }
}
