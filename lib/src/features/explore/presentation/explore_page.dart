import 'dart:async';
import '../../../core/localization/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../event_detail/presentation/pages/event_detail_page.dart';
import '../../home/data/event_filters.dart';
import '../../home/data/event_repository.dart';
import '../../home/presentation/widgets/event_tile.dart';
import 'bloc/explore_cubit.dart';
import 'widgets/filter_sheet.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => ExploreCubit(context.read<EventRepository>())..start(),
    child: const _ExploreView(),
  );
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();
  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  final search = TextEditingController();
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  void onSearch(String value) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      final cubit = context.read<ExploreCubit>();
      cubit.apply(cubit.state.filters.copyWith(search: value));
    });
  }

  Future<void> openFilters() async {
    debounce?.cancel();
    final cubit = context.read<ExploreCubit>();
    final filters = await showModalBottomSheet<EventFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FilterSheet(
        initial: cubit.state.filters,
        categories: cubit.state.categories,
      ),
    );
    if (filters != null && mounted) {
      cubit.apply(filters.copyWith(search: search.text));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.of(context, 'explore'),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: AppText.of(context, 'search'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: openFilters,
                icon: const Icon(Icons.tune_rounded),
                tooltip: AppText.of(context, 'filters'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<ExploreCubit, ExploreState>(
            builder: (context, state) {
              if (!state.filters.isFiltered) {
                return const SizedBox.shrink();
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    search.clear();
                    context.read<ExploreCubit>().apply(const EventFilters());
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(AppText.of(context, 'clear_filters')),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocConsumer<ExploreCubit, ExploreState>(
              listenWhen: (a, b) => a.error != b.error && b.error != null,
              listener: (context, state) => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!))),
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final upcoming = state.events
                    .where((event) => !event.isPast)
                    .toList();
                if (upcoming.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_busy_outlined, size: 44),
                        const SizedBox(height: 12),
                        Text(state.error ?? 'Mos tadbir topilmadi'),
                        TextButton(
                          onPressed: () =>
                              context.read<ExploreCubit>().apply(state.filters),
                          child: const Text('Yangilash'),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ExploreCubit>().apply(state.filters),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: upcoming.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == upcoming.length) {
                        return Center(
                          child: TextButton(
                            onPressed: state.loadingMore
                                ? null
                                : context.read<ExploreCubit>().loadMore,
                            child: state.loadingMore
                                ? const CircularProgressIndicator()
                                : const Text('Yana yuklash'),
                          ),
                        );
                      }
                      final event = upcoming[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(
                              preview: event,
                              heroTag: 'event-cover-${event.documentId}',
                            ),
                          ),
                        ),
                        child: EventTile(event: event),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
