import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

enum Flavor { prod, staging, dev }

class AppConfiguration {
  static String env = 'prod'; // Set your default environment here
}

class AppConfig {
  final String appName;
  final String baseUrl;
  final Color primaryColor;
  final Flavor flavor;
  final AppConfiguration configuration; // Add this field

  AppConfig._({
    required this.appName,
    required this.baseUrl,
    required this.primaryColor,
    required this.flavor,
    required this.configuration, // Initialize the field
  });

  factory AppConfig.prod(AppConfiguration configuration) {
    return AppConfig._(
      appName: "Machi",
      baseUrl: PY_PROD,
      primaryColor: Colors.black,
      flavor: Flavor.prod,
      configuration: configuration, // Initialize the field
    );
  }

  factory AppConfig.staging(AppConfiguration configuration) {
    return AppConfig._(
      appName: "Machi UAT",
      baseUrl: PY_UAT,
      primaryColor: Colors.blue,
      flavor: Flavor.staging,
      configuration: configuration, // Initialize the field
    );
  }

  factory AppConfig.dev(AppConfiguration configuration) {
    return AppConfig._(
      appName: "Machi Dev",
      baseUrl: PY_DEV,
      primaryColor: Colors.red,
      flavor: Flavor.dev,
      configuration: configuration, // Initialize the field
    );
  }

  static late final AppConfig shared = _getAppConfigForFlavor(Flavor.dev);

  static AppConfig _getAppConfigForFlavor(Flavor flavor) {
    final configuration = AppConfiguration(); // Create an instance
    switch (flavor) {
      case Flavor.prod:
        return AppConfig.prod(configuration);
      case Flavor.staging:
        return AppConfig.staging(configuration);
      case Flavor.dev:
        return AppConfig.dev(configuration);
    }
  }
}
