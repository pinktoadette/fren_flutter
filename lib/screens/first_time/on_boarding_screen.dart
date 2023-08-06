import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/first_time/sign_up_screen.dart';
import 'package:onboarding/onboarding.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late AppLocalizations _i18n;
  late List<PageModel> onboardingPagesList;
  int index = 0;
  List<Map<String, String>> captions = [
    {
      "caption": "Hey fren, happy to see you here at Machi",
      "subtitle":
          "We call bots here machi. You can talk to different kinds and discover others.",
    },
    {
      "caption": "Save the best messages",
      "subtitle": "Keep the gems from ChatGPT for later laughs.",
    },
    {
      "caption": "Get artsy with the Image Generator Library",
      "subtitle":
          "We've got a bunch of image models you can choose from – watch your imagination come to life",
    },
    {
      "caption": "Turn collections into stories",
      "subtitle":
          "Edit and add text/images to create captivating stories to save or share. \n\nLet's rock this Machi adventure together! 💫🔥",
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    List<PageModel> onboardingPagesList = List.generate(4, (index) {
      int num = index + 1;
      return PageModel(
        widget: Column(
          children: [
            Card(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/walkthrough/walk$num.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(
              captions[index]['title'] ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              captions[index]['subtitle'] ?? "",
            ),
          ],
        ),
      );
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            child: Text(
              'skip',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Onboarding(
        pages: onboardingPagesList,
        onPageChange: (int pageIndex) {
          setState(() {
            index = pageIndex;
          });
        },
        startPageIndex: 0,
        footerBuilder: (context, dragDistance, pagesLength, setIndex) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                width: 0.0,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            child: ColoredBox(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(45.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIndicator(
                      netDragPercent: dragDistance,
                      pagesLength: pagesLength,
                      indicator: Indicator(
                        activeIndicator: const ActiveIndicator(
                          color: APP_ACCENT_COLOR,
                          borderWidth: 0.7,
                        ),
                        indicatorDesign: IndicatorDesign.line(
                          lineDesign: LineDesign(
                            lineType: DesignType.line_uniform,
                          ),
                        ),
                      ),
                    ),
                    index == pagesLength - 1
                        ? ElevatedButton(
                            child: Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: Text(
                                _i18n.translate("continue"),
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                          )
                        : _nextButton(setIndex: setIndex)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Material _nextButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: defaultSkipButtonColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          setIndex!(index + 1);
        },
        child: const Padding(
          padding: defaultSkipButtonPadding,
          child: Text(
            'Next',
            style: defaultSkipButtonTextStyle,
          ),
        ),
      ),
    );
  }
}
