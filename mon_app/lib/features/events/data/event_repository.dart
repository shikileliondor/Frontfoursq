import '../domain/models/event.dart';
import 'event_api_data_source.dart';
import 'events.dart';

class EventRepository {
  EventRepository({EventApiDataSource? apiDataSource})
    : _apiDataSource = apiDataSource ?? EventApiDataSource();

  final EventApiDataSource _apiDataSource;

  Future<List<Event>> getUpcomingEvents() async {
    try {
      final remoteEvents = await _apiDataSource.fetchEvents();
      if (remoteEvents.isNotEmpty) return remoteEvents;
    } catch (_) {
      // Offline/API fallback.
    }
    return fallbackEvents;
  }
}
