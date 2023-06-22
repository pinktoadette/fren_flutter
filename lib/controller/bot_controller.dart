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
    final Bot botNow = await botApi.getBot(botId: botId);
    _currentBot = botNow.obs;
    _currentBot.refresh();
  }
}
