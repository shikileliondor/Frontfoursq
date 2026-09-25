import 'package:flutter/material.dart';

import '../../../../core/presentation/refreshable_scroll_view.dart';
import '../../data/event_repository.dart';
import '../../domain/models/event.dart';
import '../widgets/event_image.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key, this.repository});

  /// Injectable pour les tests : sans cela, la page ne peut etre
  /// exercee qu'au travers d'un vrai appel reseau.
  final EventRepository? repository;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventRepository _repository =
      widget.repository ?? EventRepository();
  late Future<List<Event>> _eventsFuture = _repository.getUpcomingEvents();

  Future<void> _refresh() async {
    final future = _repository.getUpcomingEvents();
    setState(() {
      _eventsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshableScrollView(
      onRefresh: _refresh,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evenements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Programme officiel Foursquare CI',
                  style: TextStyle(color: Color(0xFF8E95A6), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        FutureBuilder<List<Event>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            final events = snapshot.data ?? const <Event>[];
            if (snapshot.connectionState == ConnectionState.waiting &&
                events.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: events.length,
                itemBuilder: (context, index) =>
                    _EventCard(event: events[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 124,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E6EC)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: EventImage(event: event, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.scopeLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFE31E2D),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${event.date} - ${event.time}',
                    style: const TextStyle(
                      color: Color(0xFF9299AA),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9299AA),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
