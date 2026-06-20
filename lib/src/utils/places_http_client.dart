/// Abstraction over HTTP transport for Places API requests.
abstract class PlacesHttpClient {
  Future<PlacesHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  });
}

class PlacesHttpResponse {
  final int statusCode;
  final String body;

  const PlacesHttpResponse({required this.statusCode, required this.body});
}
