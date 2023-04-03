import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:get/get.dart';
import 'package:fren_app/datas/bot.dart';
import 'package:fren_app/models/bot_model.dart';

class BotController extends GetxController {
  Rx<Bot> _currentBot = Bot(
          botId: DEFAULT_BOT_ID,
          profilePhoto: '',
          about: '',
          name: '',
          model: '',
          domain: '',
          subdomain: '',
          prompt: 'You are OpenAI.',
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
    await fetchCurrentBot(DEFAULT_BOT_ID);
    super.onInit();
  }

  Future<void> fetchCurrentBot(String botId) async {
    DocumentSnapshot<Map<String, dynamic>> bot = await BotModel().getBot(botId);
    final Bot botNow = Bot.fromDocument(bot.data()!);
    _currentBot = botNow.obs;
  }
}
