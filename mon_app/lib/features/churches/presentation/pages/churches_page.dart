import 'package:flutter/material.dart';

import '../../../../core/presentation/refreshable_scroll_view.dart';
import '../../data/church_repository.dart';
import '../../domain/models/church.dart';
import '../widgets/church_card.dart';
import 'church_detail_page.dart';

class ChurchesPage extends StatefulWidget {
  const ChurchesPage({super.key, this.repository});

  /// Injectable pour les tests : sans cela, la page ne peut etre
  /// exercee qu'au travers d'un vrai appel reseau.
  final ChurchRepository? repository;

  @override
  State<ChurchesPage> createState() => _ChurchesPageState();
}

class _ChurchesPageState extends State<ChurchesPage> {
  late final ChurchRepository _repository =
      widget.repository ?? ChurchRepository();
  String _query = '';
  Church? _selectedChurch;
  late Future<List<Church>> _churchesFuture = _repository.getChurches();

  void _search(String value) {
    setState(() {
      _query = value;
      _churchesFuture = _repository.getChurches(search: _query);
    });
  }

  /// Conserve la recherche en cours : tirer ne doit pas vider le champ.
  Future<void> _refresh() async {
    final future = _repository.getChurches(search: _query);
    setState(() {
      _churchesFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final selectedChurch = _selectedChurch;
    if (selectedChurch != null) {
      return ChurchDetailPage(
        church: selectedChurch,
        onBack: () => setState(() => _selectedChurch = null),
      );
    }

    return RefreshableScrollView(
      onRefresh: _refresh,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_Header(onChanged: _search)],
            ),
          ),
        ),
        FutureBuilder<List<Church>>(
          future: _churchesFuture,
          builder: (context, snapshot) {
            final churches = snapshot.data ?? const <Church>[];

            if (snapshot.connectionState == ConnectionState.waiting &&
                churches.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (churches.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  message: _query.trim().isEmpty
                      ? 'Aucune eglise disponible'
                      : 'Aucune eglise trouvee',
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: churches.length,
                itemBuilder: (context, index) {
                  final church = churches[index];
                  return ChurchCard(
                    church: church,
                    onTap: () => setState(() => _selectedChurch = church),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eglises',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Annuaire Foursquare Cote dIvoire',
          style: TextStyle(
            color: Color(0xFF8E95A6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Rechercher une eglise...',
            hintStyle: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF111827),
            ),
            filled: true,
            fillColor: const Color(0xFFF0F1F5),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
