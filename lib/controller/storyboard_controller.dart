import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:get/get.dart';

Storyboard initial = Storyboard(
    storyboardId: '',
    title: '',
    category: '',
    summary: '',
    createdBy: StoryUser(
        photoUrl: UserModel().user.userProfilePhoto,
        userId: UserModel().user.userId,
        username: UserModel().user.username),
    story: [],
    status: StoryStatus.UNPUBLISHED,
    createdAt: getDateTimeEpoch(),
    updatedAt: getDateTimeEpoch());

class StoryboardController extends GetxController {
  RxList<Storyboard> _stories = <Storyboard>[].obs;
  // ignore: prefer_final_fields
  Rx<Storyboard> _currentStory = initial.obs;

  Storyboard get currentStory => _currentStory.value;
  set currentStory(Storyboard value) => _currentStory.value = value;

  List<Storyboard> get stories => _stories;
  set stories(List<Storyboard> value) => _stories.value = value;

  RxList<Storyboard> unpublished = <Storyboard>[].obs;
  RxList<Storyboard> published = <Storyboard>[].obs;

  @override
  void onInit() async {
    // fetchMyStories();
    super.onInit();
  }

  Future<void> fetchMyStories() async {
    final storyApi = StoryApi();
    final List<Storyboard> stories = await storyApi.getMyStories();
    _stories = stories.obs;
    _stories.refresh();
  }

  Future<void> myStories(List<Storyboard> stories) async {
    _stories = stories.obs;
    _stories.refresh();
  }

  void addNewStoryboard(Storyboard story) async {
    _stories.insert(0, story);
    _stories.refresh();
  }

  void updateStoryboard(Storyboard story) async {
    // find story index
    int index = _stories
        .indexWhere((element) => element.storyboardId == story.storyboardId);
    _stories[index] = story;
    _stories.refresh();
  }

  void setCurrentBoard(Storyboard story) async {
    currentStory = story;
  }

  getUnpublised() {
    unpublished.assignAll(_stories
        .where((element) => element.status == StoryStatus.UNPUBLISHED)
        .toList());
  }

  getPublished() {
    published.assignAll(_stories
        .where((element) => element.status == StoryStatus.PUBLISHED)
        .toList());
  }
}
