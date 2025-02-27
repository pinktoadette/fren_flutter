import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/reward_ads.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/story_cover.dart';

// ignore: must_be_immutable
class ImagePromptGeneratorWidget extends StatefulWidget {
  int? numImages;
  bool? isProfile;
  String appendPrompt;

  final Function(String url) onImageSelected;

  /// if user clicks button, parnet widget will show some tutorials, other distractions
  final Function(bool onclick) onButtonClicked;

  /// notify when the the images are returned
  final Function(bool onImages) onImageReturned;

  /// notify when there's an error
  final Function(String errorMessage) onError;

  ImagePromptGeneratorWidget(
      {Key? key,
      required this.onImageSelected,
      required this.onImageReturned,
      required this.onButtonClicked,
      required this.onError,
      this.numImages = 4,
      this.isProfile = false,
      this.appendPrompt = ""})
      : super(key: key);

  @override
  State<ImagePromptGeneratorWidget> createState() =>
      _ImagePromptGeneratorWidgetState();
}

class _ImagePromptGeneratorWidgetState extends State<ImagePromptGeneratorWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  SubscribeController subscribeController = Get.find(tag: 'subscribe');
  List<dynamic> _items = [];
  String _selectedUrl = '';
  String _appendPrompt = '';
  bool _isLoading = false;
  String status = '';
  int _counter = 1;
  late AppLocalizations _i18n;
  late Size size;
  final _cancelToken = CancelToken();
  final _promptController = TextEditingController();

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
      _counter = subscribeController.token.netCredits;
    }
    _appendPrompt = widget.appendPrompt;
  }

  @override
  void dispose() {
    super.dispose();
    _promptController.dispose();
    _cancelToken.cancel();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (widget.appendPrompt != "") {
      setState(() {
        _appendPrompt = widget.appendPrompt;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool is480v = _appendPrompt.contains("480v");
    return Column(
      children: [
        if (_items.isEmpty && _isLoading == false)
          TextField(
            onTapOutside: (b) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintStyle: const TextStyle(color: APP_MUTED_COLOR, fontSize: 14),
              hintText: _i18n.translate("sign_up_profile_ai_prompt_hint"),
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
            ),
            controller: _promptController,
            maxLines: 3,
            maxLength: 200,
          ),
        if (_items.isEmpty && _isLoading == true)
          SizedBox(
              height: 200,
              child: RewardAds(
                text: _i18n.translate("watch_ads_waiting"),
                onAdStatus: (data) {
                  /// Give token
                },
              )),
        _items.isNotEmpty
            ? SizedBox(
                width: size.width,
                height: size.width,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      crossAxisCount: 2,
                      mainAxisExtent: is480v ? size.width / 2 : null),
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
                            margin: const EdgeInsets.all(0),
                            child: StoryCover(
                                width: is480v ? size.width / 2 : size.width,
                                height: is480v ? size.width / 1.5 : size.width,
                                photoUrl: _items[index],
                                title: "image $index"),
                          ),
                        ));
                  },
                ))
            : const SizedBox(
                height: 300,
              ),
        _items.isNotEmpty
            ? ElevatedButton(
                onPressed: () {
                  widget.onImageSelected(_selectedUrl);
                },
                child: Text(_i18n.translate("OK")))
            : Align(
                alignment: Alignment.bottomCenter,
                child: TextButton.icon(
                  icon: _isLoading
                      ? loadingButton(size: 12, color: APP_ACCENT_COLOR)
                      : const SizedBox.shrink(),
                  label: Text(
                    "${_i18n.translate("profile_image_generate_button")} $status",
                  ),
                  onPressed: () {
                    if (_promptController.text.length < 10) {
                      return _insufficientPrompt();
                    }
                    if (_isLoading) {
                      null;
                    } else {
                      widget.onButtonClicked(true);
                      _generatePhoto();
                    }
                  },
                )),
        const SizedBox(
          height: 100,
        )
      ],
    );
  }

  void _insufficientPrompt() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(_i18n.translate("validation_warning")),
              content: Text(_i18n.translate("validation_prompt")),
              actions: <Widget>[
                TextButton(
                  child: Text(_i18n.translate('OK')),
                  onPressed: () => {Navigator.pop(context)},
                ),
              ],
            ));
  }

  void _listenForChanges(dynamic data) async {
    try {
      final botApi = BotApi();
      final response = await botApi.imageListener(
          id: data['id'],
          isSubscribed: widget.isProfile == true ? false : true,
          cancelToken: _cancelToken,
          statusCallback: (s) => {
                setState(() {
                  status = s;
                  _isLoading = true;
                })
              });
      if (response['status'] == 'succeeded') {
        setState(() {
          _items = response['output'];
          _counter -= 1;
        });
        subscribeController.getCredits();
        widget.onImageReturned(true);
        setState(() {
          _isLoading = false;
          status = '';
        });
      }
    } catch (err, stack) {
      widget.onError(err.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generatePhoto() async {
    if (_counter == 0) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      /// if it is profile, do not debit to subscribe.
      final botApi = BotApi();
      String sdxlProfile = widget.isProfile == true ? 'sdxl' : '';
      dynamic imageUrl = await botApi.machiImage(
          text: "${_promptController.text} $_appendPrompt $sdxlProfile",
          numImages: widget.numImages ?? 1,
          isSubscribed: widget.isProfile == true ? false : true,
          cancelToken: _cancelToken);

      if (imageUrl['status'] != 'succeeded') {
        _listenForChanges(imageUrl);
        setState(() {
          status = 'starting';
          _isLoading = true;
        });
        return;
      }

      setState(() {
        _items = imageUrl;
        _counter -= 1;
        status = '';
        _isLoading = false;
      });
      subscribeController.getCredits();
      widget.onImageReturned(true);
    } on DioException catch (err, s) {
      String message = err.response?.data["message"] ?? "";
      widget.onError(message);
      setState(() {
        _isLoading = false;
      });
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Error in image generator ${err.toString()}', fatal: true);
    }
  }
}
