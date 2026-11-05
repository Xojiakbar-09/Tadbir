import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tadbir_go/src/features/event_detail/presentation/pages/event_detail_page.dart';

import '../../data/event_model.dart';
import '../../data/event_repository.dart';
import '../bloc/home_bloc.dart';
import '../widgets/event_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(context.read<EventRepository>())..add(HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _search = TextEditingController();

  Timer? _debounce;
  String? _category;

  void _update() {
    context.read<HomeBloc>().add(
      HomeQueryChanged(_search.text.trim(), _category),
    );
  }

  void _onSearch(String text) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), _update);
  }

  void _openDetail(EventModel event, {required String source}) {
    final tag = 'event-cover-$source-${event.documentId}';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailPage(preview: event, heroTag: tag),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final bg = dark
        ? Theme.of(context).scaffoldBackgroundColor
        : const Color(0xFFF9F8FC);

    return ColoredBox(
      color: bg,
      child: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final categories = state is HomeLoaded ? state.categories : [];

            final events = state is HomeLoaded
                ? state.events.where((event) => !event.isPast).toList()
                : <EventModel>[];

            final featured = events.where((event) => event.isFeatured).toList();

            return RefreshIndicator(
              color: lavender,
              onRefresh: () async {
                final bloc = context.read<HomeBloc>();

                bloc.add(HomeRefreshed());

                await bloc.stream.firstWhere(
                  (state) => state is HomeLoaded || state is HomeError,
                );
              },

              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TADBIR • GO',
                              style: TextStyle(
                                color: lavender,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Yangi taassurotlar',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              'O‘zingizga mos tadbirni toping',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      CircleAvatar(
                        backgroundColor: dark
                            ? Colors.white12
                            : const Color(0xFFEEE8FC),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: lavender,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SEARCH
                  TextField(
                    controller: _search,
                    onChanged: _onSearch,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Tadbirlarni qidiring...',

                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: lavender,
                      ),

                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _debounce?.cancel();
                                _search.clear();

                                setState(() {});
                                _update();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),

                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,

                      contentPadding: const EdgeInsets.symmetric(vertical: 15),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(color: Color(0xFFE8E2F0)),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide(
                          color: dark
                              ? Colors.white12
                              : const Color(0xFFE8E2F0),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: lavender,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // CATEGORIES
                  const _Section('Kategoriyalar'),

                  const SizedBox(height: 13),

                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          title: 'Barchasi',
                          selected: _category == null,
                          onTap: () {
                            setState(() {
                              _category = null;
                            });
                            _debounce?.cancel();
                            _update();
                          },
                        ),

                        ...categories.map(
                          (category) => _CategoryChip(
                            title: category.name,
                            selected: _category == category.slug,
                            onTap: () {
                              setState(() {
                                _category = category.slug;
                              });
                              _debounce?.cancel();
                              _update();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 27),

                  if (state is HomeLoaded && state.loadMoreError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.loadMoreError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],

                  // LOADING
                  if (state is HomeLoading) ...[
                    const SizedBox(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(color: lavender),
                      ),
                    ),
                  ]
                  // ERROR
                  else if (state is HomeError) ...[
                    const SizedBox(height: 30),

                    Center(
                      child: Column(
                        children: [
                          Text(state.message, textAlign: TextAlign.center),

                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: () {
                              context.read<HomeBloc>().add(HomeRefreshed());
                            },
                            child: const Text('Qayta urinish'),
                          ),
                        ],
                      ),
                    ),
                  ]
                  // EVENTS
                  else if (state is HomeLoaded) ...[
                    // FEATURED EVENTS
                    if (featured.isNotEmpty) ...[
                      const _Section('Tavsiya etilgan'),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 350,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: featured.length,

                          separatorBuilder: (_, index) =>
                              const SizedBox(width: 12),

                          itemBuilder: (context, index) {
                            final event = featured[index];

                            final tag =
                                'event-cover-featured-${event.documentId}';

                            return SizedBox(
                              width: 290,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),

                                onTap: () =>
                                    _openDetail(event, source: 'featured'),

                                child: EventTile(
                                  event: event,
                                  featured: true,
                                  heroTag: tag,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 26),
                    ],

                    // UPCOMING EVENTS
                    const _Section('Yaqinlashayotgan tadbirlar'),

                    const SizedBox(height: 13),

                    if (events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Bu qidiruv bo‘yicha '
                            'tadbir topilmadi.',
                          ),
                        ),
                      ),

                    ...events.map((event) {
                      final tag = 'event-cover-upcoming-${event.documentId}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),

                          onTap: () => _openDetail(event, source: 'upcoming'),

                          child: EventTile(
                            event: event,
                            featured: false,
                            heroTag: tag,
                          ),
                        ),
                      );
                    }),

                    // LOAD MORE
                    if (state.hasMore)
                      Center(
                        child: TextButton(
                          onPressed: state.loadingMore
                              ? null
                              : () {
                                  context.read<HomeBloc>().add(HomeLoadMore());
                                },

                          child: Text(
                            state.loadingMore
                                ? 'Yuklanmoqda...'
                                : 'Yana ko‘rsat',
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// SECTION TITLE

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
    );
  }
}

// CATEGORY CHIP

class _CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),

      child: ChoiceChip(
        label: Text(title),
        selected: selected,
        onSelected: (_) => onTap(),

        labelStyle: TextStyle(
          color: selected ? Colors.white : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),

        selectedColor: lavender,
        showCheckmark: false,

        side: BorderSide(
          color: selected ? lavender : Theme.of(context).dividerColor,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
