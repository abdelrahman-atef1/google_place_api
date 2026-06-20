import 'package:flutter_test/flutter_test.dart';
import 'package:google_place_api/google_place_api.dart';
import 'package:google_place_api/src/utils/network_utility.dart';

void main() {
  group('NetworkUtility.buildPlacesUri', () {
    const authority = 'maps.googleapis.com';
    const path = 'maps/api/place/autocomplete/json';
    const params = {'input': 'cairo', 'key': 'secret-key'};

    test('directRest strips key and builds operation segment', () {
      final uri = NetworkUtility.buildPlacesUri(
        proxyUrl: null,
        proxyConfig: const PlacesProxyConfig(
          mode: PlacesProxyMode.directRest,
          proxyBaseUrl:
              'https://api.test.hi-share.net/api/v1/proxy/google/places',
        ),
        uriBuilder: null,
        operation: PlacesOperation.autocomplete,
        authority: authority,
        unencodedGoogleMapsPath: path,
        queryParameters: params,
      );

      expect(
        uri.toString(),
        'https://api.test.hi-share.net/api/v1/proxy/google/places/autocomplete?input=cairo',
      );
    });

    test('directRest details uses details segment', () {
      final uri = NetworkUtility.buildPlacesUri(
        proxyUrl: null,
        proxyConfig: const PlacesProxyConfig(
          mode: PlacesProxyMode.directRest,
          proxyBaseUrl:
              'https://api.test.hi-share.net/api/v1/proxy/google/places',
        ),
        uriBuilder: null,
        operation: PlacesOperation.details,
        authority: authority,
        unencodedGoogleMapsPath: 'maps/api/place/details/json',
        queryParameters: {'place_id': 'ChIJ...', 'key': 'secret-key'},
      );

      expect(
        uri.toString(),
        'https://api.test.hi-share.net/api/v1/proxy/google/places/details?place_id=ChIJ...',
      );
    });

    test('legacy forwarder proxyUrl unchanged', () {
      final uri = NetworkUtility.buildPlacesUri(
        proxyUrl: 'https://localhost:6969/proxy?url=',
        proxyConfig: null,
        uriBuilder: null,
        operation: PlacesOperation.autocomplete,
        authority: authority,
        unencodedGoogleMapsPath: path,
        queryParameters: Map<String, String?>.from(params),
      );

      expect(uri.host, 'localhost');
      expect(uri.port, 6969);
      expect(uri.path, '/proxy');
      expect(uri.queryParameters['input'], 'cairo');
      expect(uri.queryParameters['key'], 'secret-key');
      expect(uri.queryParameters['url'], isNotNull);
      expect(uri.queryParameters['url'], contains('maps.googleapis.com'));
    });

    test('uriBuilder has highest priority', () {
      final uri = NetworkUtility.buildPlacesUri(
        proxyUrl: 'https://ignored',
        proxyConfig: const PlacesProxyConfig(
          mode: PlacesProxyMode.directRest,
          proxyBaseUrl: 'https://also-ignored',
        ),
        uriBuilder: ({
          required PlacesOperation operation,
          required Map<String, String?> queryParameters,
        }) =>
            Uri.parse('https://custom.example/${operation.name}'),
        operation: PlacesOperation.textSearch,
        authority: authority,
        unencodedGoogleMapsPath: path,
        queryParameters: params,
      );

      expect(uri.toString(), 'https://custom.example/textSearch');
    });

    test('no proxy uses direct Google URL', () {
      final uri = NetworkUtility.buildPlacesUri(
        proxyUrl: null,
        proxyConfig: null,
        uriBuilder: null,
        operation: PlacesOperation.autocomplete,
        authority: authority,
        unencodedGoogleMapsPath: path,
        queryParameters: params,
      );

      expect(uri.host, authority);
      expect(uri.path, '/$path');
      expect(uri.queryParameters['key'], 'secret-key');
    });
  });
}
