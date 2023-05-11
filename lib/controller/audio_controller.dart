import 'package:get/get.dart';

/// Tracks current audio that is playing
/// Note: Cannot set the just_audio in controller, can only do in the widget
class AudioController extends GetxController {
  RxBool hasActive = false.obs;
  RxString text = ''.obs;
  RxMap person = {}.obs;
  RxInt audioId = 0.obs; // just_audio id 1004128165
}
