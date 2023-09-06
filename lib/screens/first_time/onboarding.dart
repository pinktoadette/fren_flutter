import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/tabs/activity_tab.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/decoration/text_border.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController(viewportFraction: 1.0, keepPage: true);

  /// language localization.
  late AppLocalizations _i18n;

  /// size of media
  late Size _size;

  /// background images
  final listBackgrounds = [
    'assets/images/onboard/onboard1.png',
    'assets/images/onboard/onboard2.png',
    'assets/images/onboard/onboard3.png',
    'assets/images/blank.png'
  ];

  /// sequence
  final steps = [1, 2, 3, 4];

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
    _size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(
      steps.length,
      (index) => Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image:
                  AssetImage(listBackgrounds[index % listBackgrounds.length]),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4), BlendMode.darken),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              if (index == 0) const AppLogo(useTheme: false),
              Container(
                padding: const EdgeInsets.all(30),
                alignment:
                    index == 0 ? Alignment.center : Alignment.bottomCenter,
                child: Semantics(
                  label: _i18n.translate("onboarding_step${index + 1}"),
                  child: TextBorder(
                      text: _i18n.translate("onboarding_step${index + 1}"),
                      textAlign: TextAlign.center,
                      size: 24,
                      useTheme: false),
                ),
              ),
              if (index != steps.length - 1)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Lottie.asset(
                    'assets/lottie/down_arrow.json',
                    width: 100,
                    height: 50,
                  ),
                ),
              const Spacer(),
            ],
          )),
    );

    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            physics: currentPageIndex == 3
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemCount: steps.length,
            itemBuilder: (_, index) {
              if (index == 3) {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ActivityTab()),
                  );
                });
              }
              return pages[index % pages.length];
            },
          ),
          Positioned(
            left: 10,
            width: 10,
            top: _size.height / 2.5,
            child: SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              axisDirection: Axis.vertical,
              effect: const ExpandingDotsEffect(
                  dotHeight: 5, dotWidth: 5, activeDotColor: APP_ACCENT_COLOR),
            ),
          ),
        ],
      ),
    ));
  }
}
