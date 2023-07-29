import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';

// ignore: must_be_immutable
class ImagePromptGeneratorWidget extends StatefulWidget {
  int? numImages;
  bool? isProfile;

  final Function(String url) onImageSelected;

  ImagePromptGeneratorWidget({
    Key? key,
    required this.onImageSelected,
    this.numImages = 4,
    this.isProfile = false,
  }) : super(key: key);

  @override
  _ImagePromptGeneratorWidgetState createState() =>
      _ImagePromptGeneratorWidgetState();
}

class _ImagePromptGeneratorWidgetState
    extends State<ImagePromptGeneratorWidget> {
  final _promptController = TextEditingController();
  SubscribeController subscribeController = Get.find(tag: 'subscribe');
  late AppLocalizations _i18n;
  List<dynamic> _items = [];
  String _selectedUrl = '';
  bool _isLoading = false;
  int _counter = 1;

  final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    childAspectRatio: 100 / 150,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    crossAxisCount: 3,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isProfile == false) {
      _counter = subscribeController.credits.value;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _promptController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        TextFormField(
          scrollPadding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: APP_MUTED_COLOR, fontSize: 14),
            hintText: _i18n.translate("profile_ai_prompt_hint"),
            isDense: true,
            contentPadding: const EdgeInsets.all(20.0),
          ),
          controller: _promptController,
          maxLines: 3,
          maxLength: 200,
        ),
        _items.isNotEmpty
            ? SizedBox(
                width: size.width,
                height: size.width,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    crossAxisCount: 2,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedUrl = _items[index];
                          });
                        },
                        child: Card(
                          color: _selectedUrl == _items[index]
                              ? APP_ACCENT_COLOR
                              : Colors.transparent,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: StoryCover(
                                photoUrl: _items[index], title: "image $index"),
                          ),
                        ));
                  },
                ))
            : const SizedBox(
                height: 350,
              ),
        _counter == 0
            ? ElevatedButton(
                onPressed: () {
                  widget.onImageSelected(_selectedUrl);
                },
                child: Text(_i18n.translate("OK")))
            : Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? loadingButton(size: 12)
                      : const SizedBox.shrink(),
                  label: Text(
                    _i18n.translate("profile_image_generate_button"),
                  ),
                  onPressed: () {
                    _generatePhoto(context);
                  },
                )),
        const SizedBox(
          height: 100,
        )
      ],
    );
  }

  void _generatePhoto(BuildContext context) async {
    if (_counter == 0) {
      return;
    }
    if (subscribeController.credits.value == 0) {
      _showSubscription(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final _botApi = BotApi();
      List<dynamic> imageUrl = await _botApi.machiImage(
          text: _promptController.text, numImages: widget.numImages);
      setState(() {
        _items = imageUrl;
        _counter -= 1;
      });
    } on DioException catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        err.response?.data["message"] ?? "Sorry, got an error 😕",
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error in image generator ${err.toString()}', fatal: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSubscription(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => Obx(() => FractionallySizedBox(
            heightFactor: subscribeController.credits.value > 0 ? 0.5 : 0.95,
            child: const SubscriptionProduct())));
  }
}
