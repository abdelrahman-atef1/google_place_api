import 'places_operation.dart';

enum PlacesProxyMode {
  /// Legacy: ?url= forwarder or path concat (existing createUri behavior).
  forwarder,

  /// Clean REST: {proxyBaseUrl}/{operationSegment}?{googleQueryParams}
  /// Strips `key` from query params (backend injects key).
  directRest,
}

typedef PlacesUriBuilder = Uri Function({
  required PlacesOperation operation,
  required Map<String, String?> queryParameters,
});

class PlacesProxyConfig {
  final PlacesProxyMode mode;

  /// e.g. https://api.test.hi-share.net/api/v1/proxy/google/places
  /// No trailing slash. No operation segment.
  final String? proxyBaseUrl;

  /// Optional override: operation → path segment on proxy.
  /// Default map:
  ///   autocomplete → autocomplete
  ///   details → details
  ///   textSearch → search
  ///   nearbySearch → nearby
  ///   findPlace → find
  ///   photo → photo
  ///   queryAutocomplete → queryautocomplete
  final Map<PlacesOperation, String>? operationPathOverrides;

  const PlacesProxyConfig({
    this.mode = PlacesProxyMode.forwarder,
    this.proxyBaseUrl,
    this.operationPathOverrides,
  });
}
