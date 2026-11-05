import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbir_go/src/features/event_detail/presentation/pages/event_detail_page.dart';

import '../../../core/localization/app_text.dart';
import '../data/event_model.dart';
import '../data/event_repository.dart';
import 'bloc/home_bloc.dart';
import 'widgets/event_tile.dart';

const _accent = Color(0xFF7656D6);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        HomeBloc(context.read<EventRepository>())..add(HomeStarted()),
    child: const _HomeView(),
  );
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _search = TextEditingController();
  Timer? _debounce;
  String? _category;

  void _query() => context.read<HomeBloc>().add(
    HomeQueryChanged(_search.text.trim(), _category),
  );

  void _onSearch(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _query);
  }

  void _pickCategory(String? category) {
    setState(() => _category = category);
    _debounce?.cancel();
    _query();
  }

  void _openDetail(EventModel event, String source) {
    final tag = 'event-cover-$source-${event.documentId}';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final muted = dark ? const Color(0xFFABA9B5) : const Color(0xFF777784);
    final surface = dark ? const Color(0xFF25252A) : Colors.white;
    final border = dark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.black.withValues(alpha: 0.055);
    final width = MediaQuery.sizeOf(context).width;
    final featuredWidth = (width - 48).clamp(260.0, 420.0).toDouble();

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final categories = state is HomeLoaded
                ? state.categories
                : <CategoryModel>[];
            final events = state is HomeLoaded ? state.events : <EventModel>[];
            final featured = events.where((e) => e.isFeatured).toList();

            return RefreshIndicator(
              color: _accent,
              onRefresh: () async {
                final bloc = context.read<HomeBloc>();
                bloc.add(HomeRefreshed());
                await bloc.stream.firstWhere(
                  (s) => s is HomeLoaded || s is HomeError,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(top: 23, bottom: 116),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TADBIR GO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: dark
                                      ? const Color(0xFFBCA8FF)
                                      : _accent,
                                  letterSpacing: 2.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppText.of(context, 'discover'),
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 31,
                                  height: 1.09,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                AppText.of(context, 'find'),
                                style: TextStyle(fontSize: 13, color: muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _GlassCircle(
                          dark: dark,
                          icon: Icons.notifications_none_rounded,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppText.of(context, 'coming_soon'),
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: TextField(
                          controller: _search,
                          onChanged: _onSearch,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: AppText.of(context, 'search'),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 23,
                            ),
                            suffixIcon: _search.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 19,
                                    ),
                                    onPressed: () {
                                      _debounce?.cancel();
                                      _search.clear();
                                      setState(() {});
                                      _query();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: surface.withValues(
                              alpha: dark ? 0.88 : 0.94,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 17,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(21),
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(21),
                              borderSide: BorderSide(color: border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(21),
                              borderSide: const BorderSide(
                                color: _accent,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _Section(title: AppText.of(context, 'categories')),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (context, index) {
                        final cat = index == 0 ? null : categories[index - 1];
                        return _CategoryPill(
                          text: cat?.name ?? AppText.of(context, 'all'),
                          selected: _category == cat?.slug,
                          onTap: () => _pickCategory(cat?.slug),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (state is HomeLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 90),
                      child: Center(
                        child: CircularProgressIndicator(color: _accent),
                      ),
                    )
                  else if (state is HomeError)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 45,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 34, color: muted),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                context.read<HomeBloc>().add(HomeRefreshed()),
                            child: Text(AppText.of(context, 'retry')),
                          ),
                        ],
                      ),
                    )
                  else if (state is HomeLoaded) ...[
                    if (featured.isNotEmpty) ...[
                      _Section(title: AppText.of(context, 'recommended')),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 344,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: featured.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final event = featured[index];
                            return SizedBox(
                              width: featuredWidth,
                              child: GestureDetector(
                                onTap: () => _openDetail(event, 'featured'),
                                child: EventTile(
                                  event: event,
                                  featured: true,
                                  heroTag:
                                      'event-cover-featured-${event.documentId}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 31),
                    ],
                    _Section(title: AppText.of(context, 'upcoming')),
                    const SizedBox(height: 15),
                    if (events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 45,
                        ),
                        child: Text(
                          AppText.of(context, 'no_events'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: muted),
                        ),
                      ),
                    ...events.map(
                      (event) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: GestureDetector(
                          onTap: () => _openDetail(event, 'upcoming'),
                          child: EventTile(
                            event: event,
                            heroTag: 'event-cover-upcoming-${event.documentId}',
                          ),
                        ),
                      ),
                    ),
                    if (state.loadMoreError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          state.loadMoreError!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    if (state.hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextButton(
                          onPressed: state.loadingMore
                              ? null
                              : () => context.read<HomeBloc>().add(
                                  HomeLoadMore(),
                                ),
                          child: Text(
                            state.loadingMore
                                ? AppText.of(context, 'loading')
                                : AppText.of(context, 'show_more'),
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

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
  );
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? (dark ? const Color(0xFFE8DFFF) : const Color(0xFF1C1C20))
          : (dark ? const Color(0xFF28282E) : Colors.white),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : (dark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.055)),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected
                    ? (dark ? const Color(0xFF24202C) : Colors.white)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.dark,
    required this.icon,
    required this.onTap,
  });
  final bool dark;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Material(
        color: dark
            ? Colors.white.withValues(alpha: .09)
            : Colors.white.withValues(alpha: .85),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: dark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: .06),
              ),
            ),
            child: Icon(icon, size: 23),
          ),
        ),
      ),
    ),
  );
}
