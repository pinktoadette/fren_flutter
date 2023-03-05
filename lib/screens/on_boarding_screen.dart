import 'package:firebase_auth/firebase_auth.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/screens/sign_up_screen.dart';
import 'package:onboarding/onboarding.dart';
import 'package:fren_app/dialogs/progress_dialog.dart';

import '../widgets/svg_icon.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  late Material materialButton;
  late int index;

  @override
  void initState() {
    super.initState();
    materialButton = _skipButton();
    index = 0;
    bool isDisabledButton = true;
  }

  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: defaultSkipButtonColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 2;
            setIndex(2);
          } else {
            return null;
          }
        },
        child: const Padding(
          padding: defaultSkipButtonPadding,
          child: Text(
            'Skip',
            style: defaultSkipButtonTextStyle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    const _pageTitleStyle = TextStyle(
      fontSize: 23.0,
      wordSpacing: 1,
      letterSpacing: 1.2,
      fontWeight: FontWeight.bold,
      color: APP_PRIMARY_COLOR,
    );

    const _pageInfoStyle = TextStyle(
      color: APP_PRIMARY_COLOR,
      letterSpacing: 0.7,
      height: 1.5,
    );

    final onboardingPagesList = [
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            border: Border.all(
              width: 0.0,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45.0,
                    vertical: 10.0,
                  ),
                  child: Image.asset('assets/images/background_image.jpg',
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        _i18n.translate('onboard_page1_title'),
                      style: _pageTitleStyle,
                      textAlign: TextAlign.left
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _i18n.translate('onboard_page1_subtitle'),
                      style: _pageInfoStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            border: Border.all(
              width: 0.0,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45.0,
                    vertical: 10.0,
                  ),
                  child: Image.asset('assets/images/background_image.jpg',
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        _i18n.translate('onboard_page2_title'),
                        style: _pageTitleStyle,
                        textAlign: TextAlign.left
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _i18n.translate('onboard_page2_subtitle'),
                      style: _pageInfoStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            border: Border.all(
              width: 0.0,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45.0,
                    vertical: 10.0,
                  ),
                  child: Image.asset('assets/images/background_image.jpg',
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        _i18n.translate('onboard_page3_title'),
                        style: _pageTitleStyle,
                        textAlign: TextAlign.left
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _i18n.translate('onboard_page3_subtitle'),
                      style: _pageInfoStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
        body: Onboarding(
          pages: onboardingPagesList,
          onPageChange: (int pageIndex) {
            index = pageIndex;
          },
          startPageIndex: 0,
          footerBuilder: (context, dragDistance, pagesLength, setIndex) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                border: Border.all(
                  width: 0.0,
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
              child: ColoredBox(
                color:  Theme.of(context).colorScheme.background,
                child: Padding(
                  padding: const EdgeInsets.all(45.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIndicator(
                        netDragPercent: dragDistance,
                        pagesLength: pagesLength,
                        indicator: Indicator(
                          indicatorDesign: IndicatorDesign.line(
                            lineDesign: LineDesign(
                              lineType: DesignType.line_uniform,
                            ),

                          ),
                        ),
                      ),
                      index == pagesLength - 1
                          ? TextButton(
                            child: Text(_i18n.translate('sign_in'),
                                style: TextStyle(color: Theme.of(context).primaryColor)),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()));
                            },
                          )
                          : _skipButton(setIndex: setIndex)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}