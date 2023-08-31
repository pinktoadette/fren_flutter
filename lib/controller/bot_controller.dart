import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/helpers/date_format.dart';

Bot frankie = Bot(
    botId: DEFAULT_BOT_ID,
    category: 'Machi',
    profilePhoto:
        'https://firebasestorage.googleapis.com/v0/b/fren-9cc3c.appspot.com/o/machi%2Ficon.png?alt=media&token=8cb6cd45-b0c6-4d32-a497-3922891961d9',
    about: 'Frankie is the default chat on Machi',
    name: 'Frankie',
    model: '',
    modelType: BotModelType.prompt,
    domain: '',
    subdomain: '',
    prompt: "",
    temperature: 0.5,
    createdAt: getDateTimeEpoch(),
    updatedAt: getDateTimeEpoch(),
    adminStatus: 'active',
    isActive: false);

class BotController extends GetxController {
  Rx<Bot> _currentBot = frankie.obs;

  Bot get bot => _currentBot.value;
  set bot(Bot value) => _currentBot.value = value;

  @override
  void onInit() async {
    // await fetchCurrentBot(DEFAULT_BOT_ID);
    super.onInit();
  }

  Future<void> fetchCurrentBot(String botId) async {
    if (botId == DEFAULT_BOT_ID) {
      // Use cached data if botId matches DEFAULT_BOT_ID
      if (_currentBot.value.name != "") {
        _currentBot.refresh();
        return; // No need to fetch from the API
      }
    } else {
      final botApi = BotApi();
      Bot botNow;
      // Fetch bot data from the API
      botNow = await botApi.getBot(botId: botId);

      // Update the cached data
      _currentBot = botNow.obs;
      _currentBot.refresh();
    }
  }
}
