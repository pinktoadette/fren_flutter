import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/date_format.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';

Storyboard initial = Storyboard(
    storyboardId: '',
    title: '',
    createdBy: StoryUser(
        photoUrl: UserModel().user.userProfilePhoto,
        userId: UserModel().user.userId,
        username: UserModel().user.username),
    scene: [],
    status: StoryStatus.UNPUBLISHED,
    createdAt: getDateTimeEpoch(),
    updatedAt: getDateTimeEpoch());

class StoryboardController extends GetxController {
  RxList<Storyboard> _stories = [initial].obs;
  // ignore: prefer_final_fields
  Rx<Storyboard> _currentStory = initial.obs;

  Storyboard get currentStory => _currentStory.value;
  set currentStory(Storyboard value) => _currentStory.value = value;

  List<Storyboard> get stories => _stories;
  set stories(List<Storyboard> value) => _stories.value = value;

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
}
