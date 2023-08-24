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
        const String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    if (activeEnv == 'prod') {
      return prod.PY_API;
    } else if (activeEnv == 'uat') {
      return uat.PY_API;
    } else if (activeEnv == 'dev') {
      return dev.PY_API;
    }

    return dev.PY_API;
  }
}
