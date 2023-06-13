import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:get/get.dart';

Storyboard initialStoryboard = Storyboard(
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

Story intialStory = Story(
    storyId: '',
    title: '',
    subtitle: '',
    createdBy: StoryUser(
        photoUrl: UserModel().user.userProfilePhoto,
        userId: UserModel().user.userId,
        username: UserModel().user.username),
    status: StoryStatus.UNPUBLISHED,
    category: '');

/// Unpublish will be _storyboards, that way you can add/edit
/// Publish variable is publish, cannot add/edit child
class StoryboardController extends GetxController {
  RxList<Storyboard> _storyboards = <Storyboard>[].obs;
  // ignore: prefer_final_fields
  Rx<Storyboard> _currentStoryboard = initialStoryboard.obs;
  Rx<Story?> _currentStory = (null).obs;

  Storyboard get currentStoryboard => _currentStoryboard.value;
  set currentStoryboard(Storyboard value) => _currentStoryboard.value = value;

  List<Storyboard> get storyboards => _storyboards;
  set storyboards(List<Storyboard> value) => _storyboards.value = value;

  Story get currentStory => _currentStory.value ?? intialStory;
  set currentStory(Story value) => _currentStory.value = value;

  RxList<Storyboard> published = <Storyboard>[].obs;

  Future<void> getBoards({StoryStatus? filter}) async {
    final storyboardApi = StoryboardApi();
    final List<Storyboard> stories =
        await storyboardApi.getMyStoryboards(statusFilter: filter?.name);
    if (filter == StoryStatus.PUBLISHED) {
      published = stories.obs;
    }
    _storyboards = stories.obs;
  }

  void addNewStoryboard(Storyboard story) async {
    _storyboards.insert(0, story);
    _storyboards.refresh();
  }

  void updateStoryboard(Storyboard story) async {
    // find storyboard index
    int index = _storyboards
        .indexWhere((element) => element.storyboardId == story.storyboardId);
    _storyboards[index] = story;
    _storyboards.refresh();
    _currentStoryboard.refresh();
  }

  void removeStoryboardfromList(Storyboard storyboard) {
    _storyboards
        .removeWhere(((item) => item.storyboardId == storyboard.storyboardId));
    _storyboards.refresh();
  }

  void setCurrentBoard(Storyboard story) async {
    _currentStoryboard = story.obs;
  }

  /// Story
  clearStory() {
    _currentStory = intialStory.obs;
  }

  void addNewStory(Story story) async {
    List<Story> stories = currentStoryboard.story!;
    stories.insert(0, story);
    Storyboard newCurrenyStoryboard = currentStoryboard.copyWith(
      story: stories,
    );
    updateStoryboard(newCurrenyStoryboard);
  }

  void removeStory(Story story) async {
    List<Story> stories = currentStoryboard.story!;
    stories.removeWhere((element) => element.storyId == story.storyId);
    Storyboard newCurrenyStoryboard = currentStoryboard.copyWith(
      story: stories,
    );
    updateStoryboard(newCurrenyStoryboard);
  }

  void setCurrentStory(Story story) {
    _currentStory = story.obs;

    List<Story> stories = currentStoryboard.story!;
    int index =
        stories.indexWhere((element) => element.storyId == story.storyId);
    currentStoryboard.story![index] = story;
    updateStoryboard(currentStoryboard);
    _currentStory.refresh();
  }

  /// Script
  void addNewScriptToStory(StoryPages page) {
    List<Story> stories = currentStoryboard.story!;

    /// update the story
    int index = stories
        .indexWhere((element) => element.storyId == currentStory.storyId);

    if (currentStoryboard.story![index].pages!.isEmpty) {
      currentStoryboard.story![index].pages!.add(page);
    } else {
      currentStoryboard.story![index].pages![page.pageNum! - 1].scripts!
          .add(page.scripts![0]);
    }

    /// update the storyboard
    updateStoryboard(currentStoryboard);
  }

  void updateStory({required Story story}) {
    List<Story> stories = currentStoryboard.story!;
    int storyIndex =
        stories.indexWhere((element) => element.storyId == story.storyId);

    // update the details of page
    currentStoryboard.story![storyIndex] = story;
    setCurrentStory(story);
    updateStoryboard(currentStoryboard);
    _currentStory = stories[storyIndex].obs;
    _currentStory.refresh();
  }
}
