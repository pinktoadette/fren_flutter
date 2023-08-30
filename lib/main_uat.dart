// ignore_for_file: constant_identifier_names

import 'package:machi_app/common_main.dart';
import 'package:machi_app/common_theme.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/server_status.dart';
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/models/app_model.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/screens/server_down.dart';
import 'package:machi_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:get/get.dart';

import 'package:leak_detector/leak_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('app.machi.channel');

// Pass the environment variable to iOS
  channel.invokeMethod('setEnvironment', {'flavor': 'uat'});

  await commonInitialization();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
// Define the Navigator global key state to be used when the build context is not available!
  final navigatorKey = GlobalKey<NavigatorState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  ServerStatus serverStatus = ServerStatus.up;

  @override
  void initState() {
    super.initState();
    LeakDetector().init(maxRetainingPath: 300);
    LeakDetector().onLeakedStream.listen((LeakedInfo info) {
      // Print to console
      debugPrint("=============== LeakedInfo Start *********************");
      debugPrint("gcRootType: ${info.gcRootType}");
      debugPrint("retainingPathJson: ${info.retainingPathJson}");

      debugPrint("Retaining Path:");
      for (var node in info.retainingPath) {
        debugPrint(node.toString());
      }
      debugPrint("=============== LeakedInfo End ***********************");

      // Show preview page
      showLeakedInfoPage(navigatorKey.currentContext!, info);
    });

    LeakDetector().onEventStream.listen((DetectorEvent event) {
      debugPrint("=============== Detector EVENT *********************");
      debugPrint(event.toString());
      if (event.type == DetectorEventType.startAnalyze) {
        debugPrint("=============== Detector Started *********************");
      } else if (event.type == DetectorEventType.endAnalyze) {
        debugPrint("=============== Detector Ended *********************");
      }
    });

    checkServerStatusWithRetries().then((status) {
      setState(() {
        serverStatus = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: ScopedModel<UserModel>(
        model: UserModel(),
        child: GetMaterialApp(
          color: Colors.transparent,
          navigatorKey: navigatorKey,
          navigatorObservers: [
            //used the LeakNavigatorObserver
            LeakNavigatorObserver(
              shouldCheck: (route) {
                return route.settings.name != null &&
                    route.settings.name != '/';
              },
            ),
          ],
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: APP_NAME,
          debugShowCheckedModeBanner: false,

          /// Setup translations
          localizationsDelegates: const [
            // AppLocalizations is where the lang translations is loaded
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: SUPPORTED_LOCALES,

          /// Returns a locale which will be used by the app
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              /// disable simplified chinese
              if (locale!.scriptCode == 'Hans') {
                return supportedLocales.first;
              }
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }

            /// If the locale of the device is not supported, use the first one
            /// from the list (English, in this case).
            return supportedLocales.first;
          },
          home: serverStatus == ServerStatus.up
              ? const SplashScreen()
              : const ServerPage(),
          themeMode: ThemeHelper().themeMode,
          theme: MainTheme.lightTheme(),
          darkTheme: MainTheme.darkTheme(),
        ),
      ),
    );
  }
}
