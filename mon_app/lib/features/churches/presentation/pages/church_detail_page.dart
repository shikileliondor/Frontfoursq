import 'package:flutter/material.dart';

import '../../domain/models/church.dart';
import '../widgets/church_image.dart';

class ChurchDetailPage extends StatelessWidget {
  const ChurchDetailPage({
    required this.church,
    required this.onBack,
    super.key,
  });

  final Church church;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.7,
                child: ChurchImage(
                  church: church,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    tooltip: 'Retour',
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 19,
                      color: Color(0xFF102A63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          sliver: SliverList.list(
            children: [
              Text(
                church.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(label: church.district, color: Color(0xFFEFF4FF)),
                  _Pill(label: church.zone, color: Color(0xFFFDF2FA)),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 36,
                child: Divider(
                  color: Color(0xFFE31E2D),
                  height: 20,
                  thickness: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'ADRESSE',
                value: church.address,
              ),
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'PASTEUR',
                value: church.pastor,
              ),
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'TELEPHONE',
                value: church.phone,
              ),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'CULTES',
                value: church.schedule,
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.near_me_outlined,
                      label: 'Itineraire',
                      color: Color(0xFFE31E2D),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.phone_outlined,
                      label: 'Appeler',
                      color: Color(0xFF102A63),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'WhatsApp',
                      color: Color(0xFF25D366),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEDEFF4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE31E2D)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF102A63),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3154C7),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
