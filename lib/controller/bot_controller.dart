import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:get/get.dart';
import 'package:machi_app/datas/bot.dart';

class BotController extends GetxController {
  Rx<Bot> _currentBot = Bot(
          botId: DEFAULT_BOT_ID,
          category: '',
          profilePhoto: '',
          about: '',
          name: '',
          model: '',
          modelType: BotModelType.prompt,
          domain: '',
          subdomain: '',
          prompt: "",
          temperature: 0.5,
          createdAt: getDateTimeEpoch(),
          updatedAt: getDateTimeEpoch(),
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
    Bot botNow;

    if (botId == DEFAULT_BOT_ID) {
      // Use cached data if botId matches DEFAULT_BOT_ID
      if (_currentBot.value.name != "") {
        _currentBot.refresh();
        return; // No need to fetch from the API
      }
    }

    // Fetch bot data from the API
    botNow = await botApi.getBot(botId: botId);

    // Update the cached data
    _currentBot = botNow.obs;
    _currentBot.refresh();
  }
}
