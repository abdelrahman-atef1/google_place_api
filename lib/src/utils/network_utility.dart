import 'package:google_place_api/google_place_api.dart';
import 'package:google_place_api/src/utils/http_places_http_client.dart';
import 'package:google_place_api/src/utils/places_http_client.dart';
import 'package:google_place_api/src/utils/places_operation.dart';
import 'package:google_place_api/src/utils/places_proxy_config.dart';

/// The Network Utility
class NetworkUtility {
  static Future<String?> fetchUrl(
    Uri uri, {
    Map<String, String>? headers,
    PlacesHttpClient? httpClient,
  }) async {
    final client = httpClient ?? HttpPlacesHttpClient();
    try {
      final response = await client.get(
        uri,
        headers: headers,
        timeout: GooglePlace.timeout,
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Builds a request URI using the configured proxy/routing priority:
  /// uriBuilder > proxyConfig.directRest > proxyUrl forwarder > direct Google.
  static Uri buildPlacesUri({
    required String? proxyUrl,
    required PlacesProxyConfig? proxyConfig,
    required PlacesUriBuilder? uriBuilder,
    required PlacesOperation operation,
    required String authority,
    required String unencodedGoogleMapsPath,
    required Map<String, String?> queryParameters,
  }) {
    if (uriBuilder != null) {
      return uriBuilder(
        operation: operation,
        queryParameters: queryParameters,
      );
    }

    if (proxyConfig != null &&
        proxyConfig.mode == PlacesProxyMode.directRest &&
        proxyConfig.proxyBaseUrl != null &&
        proxyConfig.proxyBaseUrl!.isNotEmpty) {
      return createDirectRestUri(
        config: proxyConfig,
        operation: operation,
        queryParameters: queryParameters,
      );
    }

    if (proxyUrl != null && proxyUrl != '') {
      return createUri(
        proxyUrl,
        authority,
        unencodedGoogleMapsPath,
        queryParameters,
      );
    }

    return Uri.https(authority, unencodedGoogleMapsPath, queryParameters);
  }

  static Uri createDirectRestUri({
    required PlacesProxyConfig config,
    required PlacesOperation operation,
    required Map<String, String?> queryParameters,
  }) {
    final segment = config.operationPathOverrides?[operation] ??
        _defaultOperationSegment(operation);
    final base = config.proxyBaseUrl!.replaceAll(RegExp(r'/+$'), '');
    final params = Map<String, String?>.from(queryParameters);
    params.remove('key');
    final filteredParams = {
      for (final entry in params.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    final uri = Uri.parse('$base/$segment');
    return uri.replace(queryParameters: filteredParams);
  }

  static String _defaultOperationSegment(PlacesOperation operation) {
    switch (operation) {
      case PlacesOperation.autocomplete:
        return 'autocomplete';
      case PlacesOperation.details:
        return 'details';
      case PlacesOperation.findPlace:
        return 'find';
      case PlacesOperation.nearbySearch:
        return 'nearby';
      case PlacesOperation.textSearch:
        return 'search';
      case PlacesOperation.photo:
        return 'photo';
      case PlacesOperation.queryAutocomplete:
        return 'queryautocomplete';
    }
  }

  /// Creates a uri with the proxy url if it is set
  /// [proxyUrl] Required parameters - can be formatted as [https://]host[:port][/path][?url-param-name>=] only https proxies are supported.
  /// [authority] Required parameters - the domain name of the google server, usually https://maps.googleapis.com
  /// [unencodedGoogleMapsPath] Required parameters - the path to the api, usually something like maps/api/...
  /// [queryParameters] Required parameters - a map of query parameters to be appended to the url
  static Uri createUri(String? proxyUrl, String authority,
      String unencodedGoogleMapsPath, Map<String, String?> queryParameters) {
    Uri uri;
    final googleApiUri = Uri.https(
      authority,
      unencodedGoogleMapsPath,
      queryParameters,
    );

    if (proxyUrl != null && proxyUrl != '') {
      bool usingHttps = true;
      String everythingAfterHostname = '';
      String proxyHostname = proxyUrl;
      if (proxyUrl.startsWith('https://')) {
        proxyHostname = proxyUrl.replaceFirst("https://", "");
        usingHttps = true;
      } else if (proxyUrl.startsWith('http://')) {
        proxyHostname = proxyUrl.replaceFirst("http://", "");
        usingHttps = false;
      }

      if (proxyHostname.contains("/")) {
        everythingAfterHostname =
            proxyHostname.substring(proxyHostname.indexOf("/"));
        proxyHostname = proxyHostname.substring(0, proxyHostname.indexOf("/"));
      }

      if (everythingAfterHostname.contains("?") &&
          everythingAfterHostname.contains("=")) {
        var proxyPath = everythingAfterHostname.substring(
            0, everythingAfterHostname.indexOf("?"));
        var parameterName = everythingAfterHostname.substring(
            everythingAfterHostname.indexOf("?") + 1,
            everythingAfterHostname.indexOf("="));
        var googleMapsUrlParam = {parameterName: googleApiUri.toString()};
        queryParameters.addAll(googleMapsUrlParam);
        if (usingHttps) {
          uri = Uri.https(
            proxyHostname,
            proxyPath,
            queryParameters,
          );
        } else {
          uri = Uri.http(
            proxyHostname,
            proxyPath,
            queryParameters,
          );
        }
      } else {
        //no parameter
        if (usingHttps) {
          uri = Uri.https(
            proxyHostname,
            '${everythingAfterHostname}https://$authority/$unencodedGoogleMapsPath',
            queryParameters,
          );
        } else {
          uri = Uri.http(
            proxyHostname,
            '${everythingAfterHostname}http://$authority/$unencodedGoogleMapsPath',
            queryParameters,
          );
        }
      }
    } else {
      uri = googleApiUri;
    }
    return uri;
  }
}
