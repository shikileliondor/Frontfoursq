import 'package:flutter/material.dart';

import '../../../events/data/events.dart';
import '../../../events/domain/models/event.dart';
import '../../../events/presentation/widgets/event_image.dart';

class UpcomingEventCard extends StatelessWidget {
  const UpcomingEventCard({this.event, this.onTap, super.key});

  final Event? event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentEvent = event ?? fallbackEvents.first;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 112,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4E6EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 108,
                height: double.infinity,
                child: EventImage(event: currentEvent, fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentEvent.scopeLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE31E2D),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentEvent.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const Spacer(),
                      _EventDetail(
                        icon: Icons.schedule_rounded,
                        label: '${currentEvent.date} - ${currentEvent.time}',
                      ),
                      const SizedBox(height: 3),
                      _EventDetail(
                        icon: Icons.location_on_outlined,
                        label: currentEvent.location,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9AA1B2),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9AA1B2)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9299AA), fontSize: 10),
          ),
        ),
      ],
    );
  }
}
