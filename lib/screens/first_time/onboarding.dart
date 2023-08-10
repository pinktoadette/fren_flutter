import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/tabs/activity_tab.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/decoration/text_border.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController(viewportFraction: 1.0, keepPage: true);
  final listBackgrounds = [
    'assets/images/onboard/onboard1.png',
    'assets/images/onboard/onboard2.png',
    'assets/images/onboard/onboard3.png',
    'assets/images/blank.png'
  ];
  final listCaptions = [
    "Prepare for a LOL escapade with machi",
    "Engage in witty banter with bots that rival a stand-up comedian",
    "Create or scroll thru epic stories and comics that would leave Shakespeare and Superman in awe",
    "Welcome to Machi"
  ];
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final pages = List.generate(
      listCaptions.length,
      (index) => Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage(listBackgrounds[index % listBackgrounds.length]),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), BlendMode.darken),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              if (index == 0) const AppLogo(),
              Container(
                padding: const EdgeInsets.all(30),
                alignment:
                    index == 0 ? Alignment.center : Alignment.bottomCenter,
                child: Semantics(
                  label: listCaptions[index],
                  child: TextBorder(
                    text: listCaptions[index],
                    textAlign: TextAlign.center,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Icon(Iconsax.arrow_down_1, size: 20),
              ),
              const SizedBox(
                height: 30,
              )
            ],
          )),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            physics: currentPageIndex == 3
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemCount: listCaptions.length,
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
            top: size.height / 2,
            child: SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              axisDirection: Axis.vertical,
              effect: const ExpandingDotsEffect(
                  dotHeight: 10,
                  dotWidth: 18,
                  activeDotColor: APP_ACCENT_COLOR),
            ),
          ),
        ],
      ),
    );
  }
}
