import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnecdoteFiltersPanel extends StatelessWidget {
  const AnecdoteFiltersPanel({
    super.key,
    required this.authors,
    required this.gazettes,
    required this.authorId,
    required this.gazetteId,
    required this.onAuthorChanged,
    required this.onGazetteChanged,
    required this.onReset,
    this.dateRange,
    this.onPickDate,
    this.onClearDate,
    this.hasQuery = false,
  });

  final Map<String, String> authors;
  final Map<String, String> gazettes;
  final String? authorId;
  final String? gazetteId;
  final ValueChanged<String?> onAuthorChanged;
  final ValueChanged<String?> onGazetteChanged;
  final VoidCallback onReset;
  final DateTimeRange? dateRange;
  final VoidCallback? onPickDate;
  final VoidCallback? onClearDate;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final active =
        [authorId, gazetteId, dateRange].where((value) => value != null).length;
    final labels = [
      if (authorId != null && authors.containsKey(authorId)) authors[authorId]!,
      if (gazetteId != null && gazettes.containsKey(gazetteId))
        gazettes[gazetteId]!,
      if (dateRange != null) _dateLabel(),
    ];
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        maintainState: true,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.tune),
        title: Text(active == 0 ? 'Filtres' : 'Filtres ($active)'),
        subtitle: labels.isEmpty
            ? null
            : Text(labels.join(' · '),
                maxLines: 2, overflow: TextOverflow.ellipsis),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth >= 440
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(
                  width: width,
                  child: _dropdown(
                    label: 'Personne',
                    allLabel: 'Toutes les personnes',
                    value: authorId,
                    options: authors,
                    onChanged: onAuthorChanged,
                  )),
              SizedBox(
                  width: width,
                  child: _dropdown(
                    label: 'Gazette',
                    allLabel: 'Toutes les gazettes',
                    value: gazetteId,
                    options: gazettes,
                    onChanged: onGazetteChanged,
                  )),
            ]);
          }),
          if (onPickDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: onPickDate,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                      dateRange == null ? 'Choisir une période' : _dateLabel(),
                      textAlign: TextAlign.center),
                )),
                if (dateRange != null)
                  IconButton(
                      tooltip: 'Effacer la période',
                      onPressed: onClearDate,
                      icon: const Icon(Icons.close)),
              ]),
            ),
          if (active > 0 || hasQuery)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Tout effacer')),
            ),
        ],
      ),
    );
  }

  String _dateLabel() {
    final date = DateFormat.yMd('fr_FR');
    return '${date.format(dateRange!.start)} – ${date.format(dateRange!.end)}';
  }

  Widget _dropdown(
      {required String label,
      required String allLabel,
      required String? value,
      required Map<String, String> options,
      required ValueChanged<String?> onChanged}) {
    final selected = options.containsKey(value) ? value! : '';
    return DropdownButtonFormField<String>(
      key: ValueKey('$label:$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      items: [
        DropdownMenuItem(
            value: '', child: Text(allLabel, overflow: TextOverflow.ellipsis)),
        for (final option in options.entries)
          DropdownMenuItem(
              value: option.key,
              child: Text(option.value, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (value) =>
          onChanged(value == null || value.isEmpty ? null : value),
    );
  }
}
