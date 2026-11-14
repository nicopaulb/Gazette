import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/screens/components/AnecdoteFiltersPanel.dart';
import 'package:gazette/screens/fragments/SearchFragment.dart';
import 'package:gazette/screens/home/components/FeedPostCard.dart';
import 'package:gazette/screens/newspaper/NewspaperViewerScreen.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/AnecdoteFilters.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarFragment extends StatefulWidget {
  @override
  State<CalendarFragment> createState() => _CalendarFragmentState();
}

class _CalendarFragmentState extends State<CalendarFragment> {
  late DateTime _selectedDay;
  late DateTime _month;
  Map<DateTime, List<Anecdote>> _byDay = {};
  Map<DateTime, List<Anecdote>> _visibleByDay = {};
  List<Anecdote> _visibleUndated = [];
  Map<String, String> _authors = {};
  Map<String, String> _gazetteOptions = {};
  Set<String> _visibleGazetteIds = {};
  String? _authorId;
  String? _gazetteId;
  bool get _filtersActive => _authorId != null || _gazetteId != null;
  Map<DateTime, List<Newspaper>> _gazettesByMonth = {};
  List<Newspaper> _gazettes = [];
  Map<String, DateTimeRange> _gazetteCoverage = {};
  List<Anecdote> _undated = [];
  bool _loading = false;
  bool _hasLoaded = false;
  bool _showUndated = false;
  String? _error;
  String? _gazetteError;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateUtils.dateOnly(DateTime.now());
    _month = DateTime(_selectedDay.year, _selectedDay.month);
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _gazetteError = null;
    });
    final gazettesRequest = _loadGazettes();
    try {
      final anecdotes = await PocketbaseService.to.getPublishedAnecdotes();
      if (!mounted) return;
      final byDay = <DateTime, List<Anecdote>>{};
      final undated = <Anecdote>[];
      for (final anecdote in anecdotes) {
        final date = anecdote.date;
        if (date == null) {
          undated.add(anecdote);
        } else {
          // Match the anecdote's calendar date without shifting it by time zone.
          final day = DateTime(date.year, date.month, date.day);
          (byDay[day] ??= []).add(anecdote);
        }
      }
      setState(() {
        _byDay = byDay;
        _undated = undated;
        _indexGazettes();
        if (!_hasLoaded) {
          if (byDay.isNotEmpty) {
            _selectedDay = byDay.keys.first;
            _month = DateTime(_selectedDay.year, _selectedDay.month);
          } else if (undated.isNotEmpty) {
            _showUndated = true;
          }
        }
        _hasLoaded = true;
      });
    } catch (e) {
      if (mounted)
        setState(() => _error =
            'Impossible de charger le calendrier. Vérifiez votre connexion puis réessayez.');
      Get.log('Calendar loading error: $e');
    } finally {
      await gazettesRequest;
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadGazettes() async {
    try {
      final gazettes = await PocketbaseService.to.getAllNewspapers();
      if (!mounted) return;
      gazettes.sort((a, b) => b.number.compareTo(a.number));
      setState(() {
        _gazettes = gazettes;
        _indexGazettes();
      });
    } catch (e) {
      if (mounted)
        setState(() => _gazetteError =
            'Impossible de charger les gazettes du calendrier.');
      Get.log('Calendar gazettes error: $e');
    }
  }

  void _indexGazettes() {
    final coverage = <String, DateTimeRange>{};
    for (final entry in _byDay.entries) {
      final month = DateTime(entry.key.year, entry.key.month);
      for (final anecdote in entry.value) {
        final gazetteId = anecdote.newspaperId;
        if (gazetteId.isEmpty) continue;
        final previous = coverage[gazetteId];
        coverage[gazetteId] = DateTimeRange(
          start: previous == null || month.isBefore(previous.start)
              ? month
              : previous.start,
          end: previous == null || month.isAfter(previous.end)
              ? month
              : previous.end,
        );
      }
    }

    final byMonth = <DateTime, List<Newspaper>>{};
    for (final gazette in _gazettes) {
      var period = coverage[gazette.id];
      // An issue's single stored date may be its publication date. Prefer the
      // period covered by its linked anecdotes, including intervening months.
      if (period == null && gazette.date != null) {
        final month = DateTime(gazette.date!.year, gazette.date!.month);
        period = DateTimeRange(start: month, end: month);
        coverage[gazette.id] = period;
      }
      if (period == null) continue;
      for (var month = period.start;
          !month.isAfter(period.end);
          month = DateTime(month.year, month.month + 1)) {
        (byMonth[month] ??= []).add(gazette);
      }
    }
    _gazetteCoverage = coverage;
    _gazettesByMonth = byMonth;
    _applyFilters(validate: true);
    if (_hasLoaded && _filtersActive) _jumpToMatchingDay();
  }

  void _applyFilters({bool validate = false}) {
    final all = [..._byDay.values.expand((posts) => posts), ..._undated];
    _authors = anecdoteAuthorOptions(all);
    final papers = <String, Newspaper>{
      for (final anecdote in all)
        if (anecdote.newspaper != null)
          anecdote.newspaper!.id: anecdote.newspaper!,
      for (final gazette in _gazettes) gazette.id: gazette,
    }.values.toList()
      ..sort((a, b) => b.number.compareTo(a.number));
    _gazetteOptions = {
      for (final gazette in papers) gazette.id: 'Gazette n° ${gazette.number}'
    };
    if (validate) {
      if (!_authors.containsKey(_authorId)) _authorId = null;
      if (!_gazetteOptions.containsKey(_gazetteId)) _gazetteId = null;
    }
    final filters = AnecdoteFilters(authorId: _authorId, gazetteId: _gazetteId);
    _visibleByDay = {};
    for (final entry in _byDay.entries) {
      final matches = entry.value.where(filters.matches).toList();
      if (matches.isNotEmpty) _visibleByDay[entry.key] = matches;
    }
    _visibleUndated = _undated.where(filters.matches).toList();
    _visibleGazetteIds = {
      for (final anecdote in [
        ..._visibleByDay.values.expand((posts) => posts),
        ..._visibleUndated
      ])
        if (anecdote.newspaperId.isNotEmpty) anecdote.newspaperId,
    };
  }

  void _updateFilters(VoidCallback update) {
    setState(() {
      update();
      _applyFilters();
      _jumpToMatchingDay();
    });
  }

  void _jumpToMatchingDay() {
    if (_showUndated && _visibleUndated.isNotEmpty) return;
    if (_visibleByDay.containsKey(_selectedDay)) {
      _showUndated = false;
      return;
    }
    final inMonth = _visibleByDay.keys
        .where((day) => day.year == _month.year && day.month == _month.month);
    if (inMonth.isNotEmpty || _visibleByDay.isNotEmpty) {
      _selectedDay =
          inMonth.isNotEmpty ? inMonth.first : _visibleByDay.keys.first;
      _month = DateTime(_selectedDay.year, _selectedDay.month);
      _showUndated = false;
    } else {
      _showUndated = _visibleUndated.isNotEmpty;
    }
  }

  DateTime? _populatedMonth(int direction) {
    final months = _visibleByDay.keys
        .map((day) => DateTime(day.year, day.month))
        .toSet()
        .toList()
      ..sort();
    final matches = months
        .where((month) =>
            direction < 0 ? month.isBefore(_month) : month.isAfter(_month))
        .toList();
    return matches.isEmpty
        ? null
        : direction < 0
            ? matches.last
            : matches.first;
  }

  void _jumpMonth(DateTime month) {
    final day = _visibleByDay.keys.firstWhere(
        (day) => day.year == month.year && day.month == month.month);
    _selectDay(day);
  }

  String? _coverageLabel(Newspaper gazette) {
    final period = _gazetteCoverage[gazette.id];
    if (period == null || period.start == period.end) return null;
    final first = period.start.year == period.end.year
        ? DateFormat.MMMM('fr_FR').format(period.start)
        : DateFormat.yMMMM('fr_FR').format(period.start);
    return '$first – ${DateFormat.yMMMM('fr_FR').format(period.end)}';
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      _month = DateTime(day.year, day.month);
      _showUndated = false;
    });
  }

  void _changeMonth(int offset) {
    final next = DateTime(_month.year, _month.month + offset);
    final days = _visibleByDay.keys
        .where((day) => day.year == next.year && day.month == next.month)
        .toList()
      ..sort();
    _selectDay(days.isEmpty ? next : days.first);
  }

  Future<void> _pickDate() async {
    final years = [
      DateTime.now().year,
      _month.year,
      ..._byDay.keys.map((day) => day.year),
      ..._gazettesByMonth.keys.map((month) => month.year)
    ]..sort();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      helpText: 'Choisir une date',
      cancelText: 'Annuler',
      confirmText: 'Choisir',
      initialDate: _selectedDay,
      firstDate: DateTime(years.first, 1, 1),
      lastDate: DateTime(years.last + 1, 12, 31),
    );
    if (mounted && picked != null) _selectDay(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = _showUndated
        ? _visibleUndated
        : _visibleByDay[_selectedDay] ?? <Anecdote>[];
    final monthCount = _visibleByDay.entries
        .where((entry) =>
            entry.key.year == _month.year && entry.key.month == _month.month)
        .fold<int>(0, (sum, entry) => sum + entry.value.length);
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text('Calendrier',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Rechercher des anecdotes',
            onPressed: () => Get.to(() => SearchFragment(
                initialAuthorId: _authorId, initialGazetteId: _gazetteId)),
            icon: const Icon(Icons.search),
          ),
          IconButton(
              tooltip: 'Aujourd’hui',
              onPressed: () => _selectDay(DateUtils.dateOnly(DateTime.now())),
              icon: const Icon(Icons.today_outlined)),
          IconButton(
              tooltip: 'Actualiser le calendrier',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: !_hasLoaded && _loading
            ? const Center(
                child: CircularProgressIndicator(
                    semanticsLabel: 'Chargement du calendrier'))
            : !_hasLoaded && _error != null
                ? Center(
                    child: RecoveryMessage(message: _error!, onRetry: _load))
                : Center(
                    child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: CustomScrollView(
                        key: const PageStorageKey('anecdote-calendar'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (_loading)
                            const SliverToBoxAdapter(
                                child: LinearProgressIndicator(
                                    semanticsLabel:
                                        'Actualisation du calendrier')),
                          if (_error != null)
                            SliverToBoxAdapter(
                                child: RecoveryMessage(
                                    message: _error!, onRetry: _load)),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            sliver: SliverToBoxAdapter(
                                child: AnecdoteFiltersPanel(
                              key: const PageStorageKey('calendar-filters'),
                              authors: _authors,
                              gazettes: _gazetteOptions,
                              authorId: _authorId,
                              gazetteId: _gazetteId,
                              onAuthorChanged: (value) =>
                                  _updateFilters(() => _authorId = value),
                              onGazetteChanged: (value) =>
                                  _updateFilters(() => _gazetteId = value),
                              onReset: () => _updateFilters(() {
                                _authorId = null;
                                _gazetteId = null;
                              }),
                            )),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            sliver: SliverToBoxAdapter(
                                child: _calendar(context, monthCount)),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            sliver: SliverToBoxAdapter(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      _showUndated
                                          ? 'Sans date'
                                          : DateFormat.yMMMMEEEEd('fr_FR')
                                              .format(_selectedDay),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(
                                      '${posts.length} ${posts.length == 1 ? 'anecdote' : 'anecdotes'}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant)),
                                ])),
                          ),
                          if (posts.isEmpty)
                            SliverToBoxAdapter(
                                child: RecoveryMessage(
                                    message: _filtersActive
                                        ? 'Aucune anecdote ne correspond aux filtres à cette date.'
                                        : 'Aucune anecdote publiée à cette date.'))
                          else
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  key: ValueKey(posts[index].id),
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: FeedPostCard(anecdote: posts[index]),
                                ),
                                childCount: posts.length,
                              )),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
                    ),
                  )),
      ),
    );
  }

  Widget _calendar(BuildContext context, int monthCount) {
    final theme = Theme.of(context);
    final first = DateTime(_month.year, _month.month);
    final leading = first.weekday - DateTime.monday;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final cells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateUtils.dateOnly(DateTime.now());
    final monthLabel = DateFormat.yMMMM('fr_FR').format(_month);
    final gazettes = (_gazettesByMonth[_month] ?? <Newspaper>[])
        .where((gazette) =>
            (_gazetteId == null || gazette.id == _gazetteId) &&
            (_authorId == null || _visibleGazetteIds.contains(gazette.id)))
        .toList();
    final previousPopulated = _populatedMonth(-1);
    final nextPopulated = _populatedMonth(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconButton(
              tooltip: 'Mois précédent',
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left)),
          Expanded(
              child: TextButton(
            onPressed: _pickDate,
            style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface),
            child: Text(
                '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          )),
          IconButton(
              tooltip: 'Mois suivant',
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height: 12),
        for (final gazette in gazettes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _gazetteLink(context, gazette),
          ),
        if (_gazetteError != null)
          RecoveryMessage(
              message: _gazetteError!, onRetry: _loading ? null : _load)
        else if (gazettes.isEmpty && !_loading)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
                _filtersActive
                    ? 'Aucune gazette correspondant aux filtres pour ce mois.'
                    : 'Aucune gazette pour ce mois.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall),
          ),
        Row(
            children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                .map((day) => Expanded(
                      child: Text(day,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ))
                .toList()),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              mainAxisExtent: 84),
          itemCount: cells,
          itemBuilder: (context, index) {
            final number = index - leading + 1;
            if (number < 1 || number > daysInMonth)
              return const SizedBox.shrink();
            final day = DateTime(_month.year, _month.month, number);
            final anecdotes = _visibleByDay[day] ?? <Anecdote>[];
            final count = anecdotes.length;
            final authors = <String, Anecdote>{
              for (final anecdote in anecdotes)
                anecdote.userId.isEmpty ? anecdote.id : anecdote.userId:
                    anecdote,
            }.values.toList();
            final authorNames = authors.map(_authorName).join(', ');
            final selected = !_showUndated && day == _selectedDay;
            final foreground =
                selected ? Colors.white : theme.colorScheme.onSurface;
            return Semantics(
              button: true,
              selected: selected,
              excludeSemantics: true,
              label:
                  '${DateFormat.yMMMMEEEEd('fr_FR').format(day)}, $count ${count == 1 ? 'anecdote' : 'anecdotes'}${authorNames.isEmpty ? '' : ', $authorNames'}${day == today ? ', aujourd’hui' : ''}',
              onTap: () => _selectDay(day),
              child: TextButton(
                onPressed: () => _selectDay(day),
                style: TextButton.styleFrom(
                  foregroundColor: foreground,
                  backgroundColor: selected
                      ? AppColorPrimary
                      : count > 0
                          ? AppColorPrimary.withValues(alpha: 0.08)
                          : null,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: day == today && !selected
                          ? const BorderSide(color: AppColorPrimary)
                          : BorderSide.none),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$number',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: foreground)),
                      const SizedBox(height: 3),
                      SizedBox(
                          height: 28,
                          child: authors.isEmpty
                              ? null
                              : _DayAuthors(authors: authors)),
                      const SizedBox(height: 3),
                      SizedBox(
                          height: 16,
                          child: count == 0
                              ? null
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('$count',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? Colors.white
                                              : AppColorPrimary)),
                                )),
                    ]),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(children: [
                IconButton(
                    tooltip: 'Mois précédent avec des anecdotes',
                    onPressed: previousPopulated == null
                        ? null
                        : () => _jumpMonth(previousPopulated),
                    icon: const Icon(Icons.skip_previous_outlined)),
                Expanded(
                    child: Text(
                        '$monthCount ${monthCount == 1 ? 'anecdote ce mois-ci' : 'anecdotes ce mois-ci'}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall)),
                IconButton(
                    tooltip: 'Mois suivant avec des anecdotes',
                    onPressed: nextPopulated == null
                        ? null
                        : () => _jumpMonth(nextPopulated),
                    icon: const Icon(Icons.skip_next_outlined)),
              ]),
              if (_visibleUndated.isNotEmpty)
                ChoiceChip(
                  label: Text('Sans date (${_visibleUndated.length})'),
                  selected: _showUndated,
                  onSelected: (selected) =>
                      setState(() => _showUndated = selected),
                ),
            ]),
      ]),
    );
  }

  Widget _gazetteLink(BuildContext context, Newspaper gazette) {
    final theme = Theme.of(context);
    final available = gazette.pdfUri?.isNotEmpty == true;
    final coverageLabel = _coverageLabel(gazette);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColorPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.newspaper_outlined, color: AppColorPrimary, size: 24),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gazette n° ${gazette.number}',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          if (coverageLabel != null)
            Text(coverageLabel, style: theme.textTheme.bodySmall),
          if (!available)
            Text('PDF indisponible', style: theme.textTheme.bodySmall),
        ])),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: !available
              ? null
              : () {
                  Get.put(NewspaperViewerController()).newspaper = gazette;
                  Get.to(() => NewspaperViewerScreen());
                },
          style: TextButton.styleFrom(foregroundColor: AppColorPrimary),
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          label: const Text('Lire'),
        ),
      ]),
    );
  }
}

String _authorName(Anecdote anecdote) {
  final user = anecdote.user;
  final name = [user?.firstname ?? '', user?.lastname ?? '']
      .where((part) => part.trim().isNotEmpty)
      .join(' ')
      .trim();
  return name.isNotEmpty ? name : user?.username ?? 'Un membre de la Gazette';
}

class _DayAuthors extends StatelessWidget {
  const _DayAuthors({required this.authors});
  final List<Anecdote> authors;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        const diameter = 22.0;
        const step = 16.0;
        final slots = ((constraints.maxWidth - diameter - 4) / step + 1)
            .floor()
            .clamp(1, 3);
        final visible = authors.take(slots).toList();
        final hidden = authors.length - visible.length;
        return Center(
            child: SizedBox(
          width: diameter + (visible.length - 1) * step + 4,
          height: 28,
          child: Stack(children: [
            for (var index = 0; index < visible.length; index++)
              Positioned(
                  left: index * step,
                  top: 0,
                  child: Tooltip(
                    message: _authorName(visible[index]),
                    child: Container(
                      width: diameter,
                      height: diameter,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle),
                      child: ClipOval(
                          child: CachedNetworkImage(
                        imageUrl: visible[index].user?.getResizedAvatar() ?? '',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ColoredBox(
                            color: AppColorPrimary,
                            child: Icon(Icons.person,
                                size: 14, color: Colors.white)),
                        errorWidget: (_, __, ___) => const ColoredBox(
                            color: AppColorPrimary,
                            child: Icon(Icons.person,
                                size: 14, color: Colors.white)),
                      )),
                    ),
                  )),
            if (hidden > 0)
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('+$hidden',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.surface)),
                  )),
          ]),
        ));
      });
}
