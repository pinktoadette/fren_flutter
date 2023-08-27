import 'package:http/http.dart' as http;

enum ServerStatus { up, down }

Future<ServerStatus> checkServerStatus() async {
  try {
    final response = await http.get(Uri.parse('https://api.mymachi.app/'));
    if (response.statusCode == 200) {
      return ServerStatus.up;
    } else {
      return ServerStatus.down;
    }
  } catch (e) {
    return ServerStatus.down;
  }
}

Future<ServerStatus> checkServerStatusWithRetries() async {
  for (int retry = 0; retry < 5; retry++) {
    final serverStatus = await checkServerStatus();
    if (serverStatus == ServerStatus.up) {
      return ServerStatus.up;
    }
    await Future.delayed(const Duration(seconds: 2));
  }
  return ServerStatus.down;
}
