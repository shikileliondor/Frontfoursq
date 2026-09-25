import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_app/features/home/data/home_api_data_source.dart';
import 'package:mon_app/features/home/data/home_repository.dart';
import 'package:mon_app/features/home/domain/models/home_snapshot.dart';

/// Reprend la forme reelle de `GET /api/v1/home`, relevee sur le serveur.
Map<String, dynamic> get _payload => {
  'success': true,
  'data': {
    'banners': <Object>[],
    'featured_news': [
      {
        'id': '01a0b954-4c51-730c-a949-b65d7c80bb6e',
        'title': 'Assemblee Generale 2026',
        'slug': 'assemblee-generale-2026',
        'excerpt': 'Le rendez-vous annuel du mouvement.',
        'scope_type': 'NATIONAL',
        'published_at': '2026-09-19T11:10:00+00:00',
        'cover': {
          'id': '01a0b47b-d004-7258-b1a3-e043ad16b21f',
          'url': 'https://api.example.test/api/v1/media/abc/file',
          'mime_type': 'image/jpeg',
        },
      },
    ],
    'featured_news_item': null,
    'featured_event': {
      'id': 'ev-1',
      'title': 'Nuit de priere',
      'slug': 'nuit-de-priere',
      'location': 'Temple central, Abidjan',
      'start_at': '2026-10-02T19:30:00+00:00',
      'scope_type': 'NATIONAL',
    },
    'latest_news': [
      {
        'id': 'n-2',
        'title': 'Seminaire des leaders',
        'slug': 'seminaire-des-leaders',
        'scope_type': 'DISTRICT',
        'published_at': '2026-09-18T08:00:00+00:00',
      },
    ],
    'upcoming_events': [
      {
        'id': 'ev-2',
        'title': 'Congres jeunesse',
        'slug': 'congres-jeunesse',
        'location': 'Bouake',
        'start_at': '2026-11-14T09:00:00+00:00',
        'scope_type': 'ZONE',
      },
    ],
  },
};

void main() {
  test('reads the whole home screen from a single request', () async {
    final requested = <Uri>[];

    final source = HomeApiDataSource(
      client: MockClient((request) async {
        requested.add(request.url);
        return http.Response(
          jsonEncode(_payload),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final snapshot = await source.fetchHome();

    // Un seul aller-retour : c'est la raison d'etre de l'endpoint /home.
    expect(requested, hasLength(1));
    expect(requested.single.path, endsWith('/home'));

    expect(snapshot.source, HomeSource.api);
    expect(snapshot.featuredArticles.single.title, 'Assemblee Generale 2026');
    expect(snapshot.latestArticles.single.title, 'Seminaire des leaders');
    expect(snapshot.upcomingEvents.single.title, 'Congres jeunesse');
    expect(snapshot.featuredEvent?.title, 'Nuit de priere');
  });

  test('maps the cover image and the publication date', () async {
    final source = HomeApiDataSource(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(_payload),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final article = (await source.fetchHome()).featuredArticles.single;

    expect(article.imageUrl, 'https://api.example.test/api/v1/media/abc/file');
    expect(article.date, '19 Sep 2026');
    expect(article.badgeLabel, 'NATIONAL');
  });

  test('prefers the event the API puts forward over the next one', () async {
    final source = HomeApiDataSource(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(_payload),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final snapshot = await source.fetchHome();

    expect(snapshot.highlightedEvent?.title, 'Nuit de priere');
  });

  test('falls back to the next event when none is put forward', () async {
    final payload = _payload;
    (payload['data'] as Map<String, dynamic>)['featured_event'] = null;

    final source = HomeApiDataSource(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(payload),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final snapshot = await source.fetchHome();

    expect(snapshot.featuredEvent, isNull);
    expect(snapshot.highlightedEvent?.title, 'Congres jeunesse');
  });

  test('rejects a body that is not the expected envelope', () async {
    final source = HomeApiDataSource(
      client: MockClient((_) async => http.Response('{"success":false}', 200)),
    );

    expect(source.fetchHome(), throwsException);
  });

  test('rejects an HTTP error', () async {
    final source = HomeApiDataSource(
      client: MockClient((_) async => http.Response('nope', 503)),
    );

    expect(source.fetchHome(), throwsException);
  });

  group('HomeRepository', () {
    test('announces the fallback when the server is unreachable', () async {
      final repository = HomeRepository(
        apiDataSource: HomeApiDataSource(
          client: MockClient((_) async => http.Response('down', 500)),
        ),
      );

      final snapshot = await repository.getHome();

      // Le point essentiel : l'ecran reste utilisable, mais il sait qu'il
      // montre du contenu de demonstration.
      expect(snapshot.source, HomeSource.fallback);
      expect(snapshot.latestArticles, isNotEmpty);
    });

    test('announces the fallback when the API has nothing to show', () async {
      final repository = HomeRepository(
        apiDataSource: HomeApiDataSource(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'featured_news': <Object>[],
                  'latest_news': <Object>[],
                  'upcoming_events': <Object>[],
                  'featured_event': null,
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        ),
      );

      expect((await repository.getHome()).source, HomeSource.fallback);
    });

    test('never throws, whatever the server answers', () async {
      final repository = HomeRepository(
        apiDataSource: HomeApiDataSource(
          client: MockClient((_) async => throw Exception('socket')),
        ),
      );

      await expectLater(repository.getHome(), completes);
    });
  });
}
