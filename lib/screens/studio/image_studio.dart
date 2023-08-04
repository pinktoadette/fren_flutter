import 'package:get/get.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/image/image_generative.dart';
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';

class ImageStudioScreen extends StatefulWidget {
  final Function(String data) onImageSelect;
  const ImageStudioScreen({Key? key, required this.onImageSelect})
      : super(key: key);

  @override
  _ImageStudioScreenState createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends State<ImageStudioScreen> {
  late AppLocalizations _i18n;
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            _i18n.translate("studio"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: const [SubscribeTokenCounter()],
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _i18n.translate("studio_draw_prompt"),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 10,
              ),
              ImagePromptGeneratorWidget(
                  onImageSelected: (value) => {widget.onImageSelect(value)}),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        )));
  }
}
