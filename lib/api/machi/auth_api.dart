import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/constants/secrets.dart';

class ErrorAndStack {
  final dynamic error;
  final StackTrace stack;

  ErrorAndStack(this.error, this.stack);
}

/// Setup auth headers for API and firebase communication.
class AuthApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();
  final myKey = MACHI_KEY;

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Dio> getPublicDio() async {
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = myKey;
    dio.options.receiveTimeout = const Duration(seconds: 180);
    dio.options.followRedirects = false;
    return dio;
  }

  Future<Dio> getDio() async {
    if (getFirebaseUser == null) {
      return await getPublicDio();
    }
    String? token = await getFirebaseUser!.getIdToken();
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = myKey;
    dio.options.headers["fb-authorization"] = token;
    dio.options.receiveTimeout = const Duration(seconds: 120);
    dio.options.followRedirects = false;
    return dio;
  }

  Future<Map<String, dynamic>> getHeaders() async {
    String? token = await getFirebaseUser!.getIdToken();
    return {"fb-authorization": token, "api-key": myKey};
  }

  Future<Dio> getAzure() async {
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = myKey;
    return dio;
  }

  Future<Response> retryGetRequest(String url,
      {int retries = 3, CancelToken? cancelToken}) async {
    Dio dio = await getDio();
    List<ErrorAndStack> errorStackList = [];

    for (int retry = 0; retry < retries; retry++) {
      try {
        final Response response = await dio.get(
          url,
          cancelToken: cancelToken,
        );

        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          return response;
        }
      } catch (error, stack) {
        errorStackList.add(ErrorAndStack(error, stack));
      }

      // Wait before retrying
      await Future.delayed(const Duration(seconds: 2));
    }

    // Record all errors and stack traces to Firebase Crashlytics
    for (var errorStack in errorStackList) {
      await FirebaseCrashlytics.instance
          .recordError(errorStack.error, errorStack.stack);
    }

    // If all retries failed, throw an exception
    throw Exception('Failed to fetch data after $retries retries');
  }
}
