import 'package:machi_app/datas/storyboard.dart';
import 'package:get/get.dart';

class TimelineController extends GetxController {
  // ignore: prefer_final_fields
  RxList<Storyboard> feedList = <Storyboard>[].obs;
  int offset = 0;
  int limit = 30;

  Stream<List<Storyboard>> get streamFeed async* {
    yield feedList;
  }

  void fetchMyTimeline(Storyboard item) {
    feedList.add(item);
    feedList.refresh();
  }
}
