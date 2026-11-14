import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/screens/components/AnecdoteFiltersPanel.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/screens/home/components/FeedPostCard.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:gazette/utils/AnecdoteFilters.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment(
      {super.key, this.initialAuthorId, this.initialGazetteId});
  final String? initialAuthorId;
  final String? initialGazetteId;

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final TextEditingController _query = TextEditingController();
  Timer? _debounce;
  List<Anecdote> _anecdotes = [];
  Map<String, String> _authors = {};
  Map<String, String> _gazettes = {};
  String? _authorId;
  String? _gazetteId;
  DateTimeRange? _dateRange;
  bool _loading = false;
  bool _hasLoaded = false;
  String? _error;
  String? _gazetteError;

  @override
  void initState() {
    super.initState();
    _authorId = widget.initialAuthorId;
    _gazetteId = widget.initialGazetteId;
    _query.addListener(_onQueryChanged);
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _gazetteError = null;
    });
    final gazettesRequest = _fetchGazettes();
    try {
      final anecdotes = await PocketbaseService.to.getPublishedAnecdotes();
      final gazettes = await gazettesRequest;
      if (!mounted) return;
      setState(() {
        _anecdotes = anecdotes;
        _authors = anecdoteAuthorOptions(anecdotes);
        final previousLabel = _gazettes[_gazetteId];
        _gazettes = {...?gazettes, ...anecdoteGazetteOptions(anecdotes)};
        if (!_authors.containsKey(_authorId)) _authorId = null;
        if (_gazetteId != null && !_gazettes.containsKey(_gazetteId)) {
          if (gazettes == null) {
            _gazettes[_gazetteId!] = previousLabel ?? 'Gazette sélectionnée';
          } else {
            _gazetteId = null;
          }
        }
        _hasLoaded = true;
      });
    } catch (e) {
      if (mounted)
        setState(() => _error =
            'Impossible de charger les anecdotes. Vérifiez votre connexion puis réessayez.');
      Get.log('Search loading error: $e');
    } finally {
      await gazettesRequest;
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Map<String, String>?> _fetchGazettes() async {
    try {
      final gazettes = await PocketbaseService.to.getAllNewspapers();
      gazettes.sort((a, b) => b.number.compareTo(a.number));
      return {
        for (final gazette in gazettes)
          gazette.id: 'Gazette n° ${gazette.number}'
      };
    } catch (e) {
      if (mounted)
        setState(() => _gazetteError =
            'Impossible de charger la liste complète des gazettes.');
      Get.log('Search gazettes loading error: $e');
      return null;
    }
  }

  void _reset() {
    _query.clear();
    _debounce?.cancel();
    setState(() {
      _authorId = null;
      _gazetteId = null;
      _dateRange = null;
    });
  }

  Future<void> _pickDates() async {
    FocusScope.of(context).unfocus();
    final years = [
      DateTime.now().year,
      1900,
      if (_dateRange != null) ...[_dateRange!.start.year, _dateRange!.end.year],
      ..._anecdotes.where((a) => a.date != null).map((a) => a.date!.year)
    ]..sort();
    final range = await showDateRangePicker(
      context: context,
      locale: const Locale('fr'),
      firstDate: DateTime(years.first, 1, 1),
      lastDate: DateTime(years.last, 12, 31),
      initialDateRange: _dateRange,
      helpText: 'Choisir une période',
      saveText: 'Appliquer',
      cancelText: 'Annuler',
    );
    if (mounted && range != null) setState(() => _dateRange = range);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = AnecdoteFilters(
        query: _query.text,
        authorId: _authorId,
        gazetteId: _gazetteId,
        dateRange: _dateRange);
    final results = _anecdotes.where(filters.matches).toList(growable: false);
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: const Text('Rechercher'),
        actions: [
          IconButton(
              tooltip: 'Actualiser les anecdotes',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                    child: TextField(
                  controller: _query,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) {
                    _debounce?.cancel();
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Rechercher une anecdote',
                    hintText: 'Mot-clé, nom ou numéro de gazette',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Effacer la recherche',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _query.clear();
                              _debounce?.cancel();
                              setState(() {});
                            }),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                )),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverToBoxAdapter(
                    child: AnecdoteFiltersPanel(
                  key: const PageStorageKey('search-filters'),
                  authors: _authors,
                  gazettes: _gazettes,
                  authorId: _authorId,
                  gazetteId: _gazetteId,
                  onAuthorChanged: (value) => setState(() => _authorId = value),
                  onGazetteChanged: (value) =>
                      setState(() => _gazetteId = value),
                  dateRange: _dateRange,
                  onPickDate: _pickDates,
                  onClearDate: () => setState(() => _dateRange = null),
                  hasQuery: _query.text.trim().isNotEmpty,
                  onReset: _reset,
                )),
              ),
              if (_loading)
                const SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: LinearProgressIndicator(
                            semanticsLabel: 'Chargement des anecdotes'))),
              if (_error != null)
                SliverToBoxAdapter(
                    child: RecoveryMessage(message: _error!, onRetry: _load)),
              if (_gazetteError != null && _error == null)
                SliverToBoxAdapter(
                    child: RecoveryMessage(
                        message: _gazetteError!,
                        onRetry: _loading ? null : _load)),
              if (_hasLoaded)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                      child: Semantics(
                          liveRegion: true,
                          child: Text(
                              '${results.length} ${results.length == 1 ? 'résultat' : 'résultats'}',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)))),
                ),
              if (_hasLoaded && results.isEmpty)
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(children: [
                    const Icon(Icons.search_off, size: 40),
                    const SizedBox(height: 12),
                    Text(
                        _anecdotes.isEmpty
                            ? 'Aucune anecdote publiée pour le moment.'
                            : 'Aucune anecdote ne correspond à votre recherche.',
                        textAlign: TextAlign.center),
                    if (_anecdotes.isNotEmpty)
                      TextButton(
                          onPressed: _reset, child: const Text('Tout effacer')),
                  ]),
                )),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                      key: ValueKey(results[index].id),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FeedPostCard(anecdote: results[index])),
                  childCount: results.length,
                )),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ))),
    );
  }
}
