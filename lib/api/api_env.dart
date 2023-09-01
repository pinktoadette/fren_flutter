import 'package:machi_app/constants/constant_prod.dart' as prod;
import 'package:machi_app/constants/constant_uat.dart' as uat;
import 'package:machi_app/constants/constant_dev.dart' as dev;

class ApiConfiguration {
  static final ApiConfiguration _instance = ApiConfiguration._internal();

  factory ApiConfiguration() {
    return _instance;
  }

  ApiConfiguration._internal();

  String getApiUrl() {
    String activeEnv =
        const String.fromEnvironment('flavor', defaultValue: 'prod');

    if (activeEnv.contains('prod')) {
      return prod.PY_API;
    } else if (activeEnv.contains('uat')) {
      return uat.PY_API;
    } else if (activeEnv.contains('dev')) {
      return dev.PY_API;
    }

    return prod.PY_API;
  }
}
