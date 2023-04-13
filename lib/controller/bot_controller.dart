import 'package:fren_app/api/machi/bot_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:get/get.dart';
import 'package:fren_app/datas/bot.dart';

class BotController extends GetxController {
  Rx<Bot> _currentBot = Bot(
          botId: DEFAULT_BOT_ID,
          profilePhoto: '',
          about: '',
          name: '',
          model: '',
          domain: '',
          subdomain: '',
          prompt: "",
          temperature: 0.5,
          createdAt: DateTime.now().microsecondsSinceEpoch,
          updatedAt: DateTime.now().microsecondsSinceEpoch,
          adminStatus: '',
          isActive: false)
      .obs;

  Bot get bot => _currentBot.value;
  set bot(Bot value) => _currentBot.value = value;

  @override
  void onInit() async {
    // await fetchCurrentBot(DEFAULT_BOT_ID);
    super.onInit();
  }

  Future<void> fetchCurrentBot(String botId) async {
    final botApi = BotApi();
    final Bot botNow = await botApi.getBot(botId: botId);
    _currentBot = botNow.obs;
  }
}
