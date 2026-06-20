import 'package:http/http.dart' as http;

import 'places_http_client.dart';

class HttpPlacesHttpClient implements PlacesHttpClient {
  final http.Client _client;

  HttpPlacesHttpClient([http.Client? client]) : _client = client ?? http.Client();

  @override
  Future<PlacesHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final future = _client.get(uri, headers: headers);
    final response =
        timeout != null ? await future.timeout(timeout) : await future;
    return PlacesHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
