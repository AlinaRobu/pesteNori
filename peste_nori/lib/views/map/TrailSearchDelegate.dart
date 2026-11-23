import 'package:flutter/material.dart';
import 'package:peste_nori/globals.dart';

import 'models/HikingRoute.dart';

class TrailSearchDelegate extends SearchDelegate<HikingRoute> {
  TrailSearchDelegate(Iterable<HikingRoute> routes)
    : _trails = routes.map((route) {
        return (
          route: route,
          searchText: _normalize(
            [
              route.displayName(translations.unnamedTrail),
              route.ref,
              route.from,
              route.to,
            ].nonNulls.join(' '),
          ),
        );
      }).toList(),
      super(searchFieldLabel: translations.searchTrails);

  final List<({HikingRoute route, String searchText})> _trails;

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[ăâ]'), 'a')
      .replaceAll('î', 'i')
      .replaceAll(RegExp('[șş]'), 's')
      .replaceAll(RegExp('[țţ]'), 't');

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: translations.clearSearch,
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
        icon: const Icon(Icons.clear),
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => const BackButton();

  @override
  Widget buildResults(BuildContext context) => _buildMatches();

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatches();

  Widget _buildMatches() {
    final search = _normalize(query.trim());
    if (search.isEmpty) {
      return Center(child: Text(translations.trailSearchHint));
    }
    final words = search.split(RegExp(r'\s+'));
    final matches = _trails
        .where((trail) => words.every(trail.searchText.contains))
        .toList();
    if (matches.isEmpty) {
      return Center(child: Text(translations.noMatchingTrails));
    }
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final route = matches[index].route;
        final details = [
          if (route.ref?.isNotEmpty == true) route.ref!,
          if (route.to?.isNotEmpty == true) route.to!,
          if (route.distanceKm != null) translations.distanceKm(route.distanceKm.toString()),
        ];
        return ListTile(
          leading: const Icon(Icons.route),
          title: Text(route.displayName(translations.unnamedTrail)),
          subtitle: details.isEmpty ? null : Text(details.join(' · ')),
          onTap: () => close(context, route),
        );
      },
    );
  }
}
