import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscribeHowToInfo extends StatefulWidget {
  const SubscribeHowToInfo({Key? key}) : super(key: key);

  @override
  State<SubscribeHowToInfo> createState() => _SubscribeHowToInfoState();
}

class _SubscribeHowToInfoState extends State<SubscribeHowToInfo> {
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');

  @override
  Widget build(BuildContext context) {
    AppLocalizations i18n = AppLocalizations.of(context);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          automaticallyImplyLeading: false,
          title: Row(children: [
            const AppLogo(),
            Container(
              margin: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                  color: APP_ACCENT_COLOR,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: const EdgeInsets.all(5),
              child: Text(
                i18n.translate("subscribe_pro"),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            )
          ]),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n.translate("subscribe_libraries"),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    i18n.translate("subscribe_how_to"),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    i18n.translate("subscribe_curent_libraries"),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Table(
                      border: TableBorder.all(
                          color:
                              APP_MUTED_COLOR), // Allows to add a border decoration around your table
                      children: const [
                        TableRow(children: [
                          Text(
                            'Library',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Text Input',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ]),
                        TableRow(children: [
                          Text('Open journey'),
                          Text('open-journey')
                        ]),
                        TableRow(
                            children: [Text('stable diffusion'), Text('sd')]),
                        TableRow(
                            children: [Text('stability sdxl'), Text('sdxl')]),
                        TableRow(children: [Text('DALL-E'), Text('dall-e')]),
                        TableRow(children: [
                          Text('Epic Realism*'),
                          Text('epic-realism')
                        ]),
                        TableRow(children: [Text('funko*'), Text('funko')]),
                        TableRow(
                            children: [Text('majicmix*'), Text('majicmix')]),
                      ]),
                  Text(
                    "* ${i18n.translate("take_time_to_load")}",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (subscribeController.credits.value == 0)
                    Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            onPressed: () {
                              _showSubscription();
                            },
                            child: Text(i18n.translate("subscribe_now")))),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () => _launchSiteUrl(SURVEY_FORM),
                    child: Text(
                      i18n.translate("subscribe_add_your_own_model"),
                    ),
                  )
                ],
              ),
            )));
  }

  void _launchSiteUrl(String uri) async {
    final Uri url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch url: $url";
    }
  }

  void _showSubscription() {
    Navigator.pop(context);
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const FractionallySizedBox(
            heightFactor: 0.97, child: SubscriptionProduct()));
  }
}
