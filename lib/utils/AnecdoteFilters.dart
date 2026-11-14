import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/NewspaperModel.dart';

final _accentPatterns = <RegExp, String>{
  RegExp('[àáâãäå]'): 'a',
  RegExp('[èéêë]'): 'e',
  RegExp('[ìíîï]'): 'i',
  RegExp('[òóôõöø]'): 'o',
  RegExp('[ùúûü]'): 'u',
  RegExp('[ýÿ]'): 'y',
  RegExp('[ç]'): 'c',
  RegExp('[ñ]'): 'n',
  RegExp(r'[\u0300-\u036f]'): '',
};

String normalizeAnecdoteSearch(String value) {
  var result = value
      .toLowerCase()
      .replaceAll('œ', 'oe')
      .replaceAll('æ', 'ae')
      .replaceAll('’', "'");
  for (final pattern in _accentPatterns.entries) {
    result = result.replaceAll(pattern.key, pattern.value);
  }
  return result;
}

String anecdoteAuthorName(Anecdote anecdote) {
  final user = anecdote.user;
  final name = [user?.firstname.trim() ?? '', user?.lastname.trim() ?? '']
      .where((part) => part.isNotEmpty)
      .join(' ');
  if (name.isNotEmpty) return name;
  return user?.username.isNotEmpty == true
      ? user!.username
      : 'Un membre de la Gazette';
}

Map<String, String> anecdoteAuthorOptions(Iterable<Anecdote> anecdotes) {
  final options = <String, String>{
    for (final anecdote in anecdotes)
      if (anecdote.userId.isNotEmpty)
        anecdote.userId: anecdoteAuthorName(anecdote),
  };
  final entries = options.entries.toList()
    ..sort((a, b) => normalizeAnecdoteSearch(a.value)
        .compareTo(normalizeAnecdoteSearch(b.value)));
  return Map.fromEntries(entries);
}

Map<String, String> anecdoteGazetteOptions(Iterable<Anecdote> anecdotes) {
  final gazettes = <String, Newspaper>{
    for (final anecdote in anecdotes)
      if (anecdote.newspaper != null)
        anecdote.newspaper!.id: anecdote.newspaper!,
  }.values.toList()
    ..sort((a, b) => b.number.compareTo(a.number));
  return {
    for (final gazette in gazettes) gazette.id: 'Gazette n° ${gazette.number}'
  };
}

class AnecdoteFilters {
  const AnecdoteFilters(
      {this.query = '', this.authorId, this.gazetteId, this.dateRange});

  final String query;
  final String? authorId;
  final String? gazetteId;
  final DateTimeRange? dateRange;

  bool matches(Anecdote anecdote) {
    if (authorId != null && anecdote.userId != authorId) return false;
    if (gazetteId != null && anecdote.newspaperId != gazetteId) return false;
    final range = dateRange;
    if (range != null) {
      final date = anecdote.date;
      if (date == null) return false;
      final day = DateTime(date.year, date.month, date.day);
      if (day.isBefore(DateUtils.dateOnly(range.start)) ||
          day.isAfter(DateUtils.dateOnly(range.end))) return false;
    }
    if (query.trim().isEmpty) return true;
    final terms = normalizeAnecdoteSearch(query)
        .trim()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty);
    if (terms.isEmpty) return true;
    final text = normalizeAnecdoteSearch(
        '${anecdote.text} ${anecdoteAuthorName(anecdote)} ${anecdote.user?.username ?? ''} ${anecdote.newspaper == null ? '' : 'gazette ${anecdote.newspaper!.number}'}');
    return terms.every(text.contains);
  }
}
