class GitHubLoginResponse {
  String accessToken;
  String tokenType;
  String scope;
  GitHubLoginResponse(
      {required this.accessToken,
      required this.tokenType,
      required this.scope});
  factory GitHubLoginResponse.fromJson(Map<String, dynamic> json) =>
      GitHubLoginResponse(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        scope: json["scope"],
      );
}

class GitHubLoginRequest {
  String clientId;
  String clientSecret;
  String code;
  GitHubLoginRequest(
      {required this.clientId, required this.clientSecret, required this.code});
  dynamic toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "code": code,
      };
}
