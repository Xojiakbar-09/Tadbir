import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/localization/app_text.dart';
import '../../../home/data/event_model.dart';
import '../../data/event_detail_repository.dart';
import '../bloc/event_detail_bloc.dart';
import '../widgets/event_location_card.dart';
import '../../../tickets/data/tickets_repository.dart';
import '../../../tickets/presentation/widgets/booking_success_dialog.dart';
import '../../../main/presentation/main_screen.dart';

const _purple = Color(0xFF7656D6);

class EventDetailPage extends StatelessWidget {
  final EventModel preview;
  final String heroTag;

  const EventDetailPage({
    super.key,
    required this.preview,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        EventDetailBloc(context.read<EventDetailRepository>())
          ..add(EventDetailRequested(preview.documentId)),
    child: _DetailBody(preview: preview, heroTag: heroTag),
  );
}

class _DetailBody extends StatefulWidget {
  final EventModel preview;
  final String heroTag;
  const _DetailBody({required this.preview, required this.heroTag});
  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final ScrollController _scroll = ScrollController();
  bool _showTitle = false;
  bool _booking = false;
  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final next = _scroll.offset > 136.5;
      if (mounted && next != _showTitle) {
        setState(() => _showTitle = next);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;
    return BlocBuilder<EventDetailBloc, EventDetailState>(
      builder: (context, state) {
        final detail = state is EventDetailLoaded ? state.detail : null;
        final event = detail?.event ?? widget.preview;
        final isPast = event.isPast;
        return Scaffold(
          backgroundColor: background,
          body: CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: background,
                foregroundColor: _showTitle
                    ? (dark ? Colors.white : Colors.black87)
                    : Colors.white,
                title: AnimatedOpacity(
                  opacity: _showTitle ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Tadbirni ulashish',
                    icon: const Icon(Icons.ios_share_outlined),
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                        text:
                            '${event.title}\n${event.city}\n${event.location}\n${_date(event.startDate)}',
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [],
                  collapseMode: CollapseMode.pin,
                  background: Hero(
                    tag: widget.heroTag,
                    child: _Cover(url: event.imageUrl),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.category.toUpperCase(),
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 22),
                      _InfoLine(
                        icon: Icons.calendar_today_outlined,
                        title: _date(event.startDate),
                        subtitle: detail?.endDate == null
                            ? 'Boshlanish vaqti'
                            : 'Tugashi: ${_date(detail!.endDate)}',
                      ),
                      const SizedBox(height: 16),
                      _InfoLine(
                        icon: Icons.location_on_outlined,
                        title: event.city,
                        subtitle: event.location.isEmpty
                            ? 'Manzil kiritilmagan'
                            : event.location,
                      ),
                      const SizedBox(height: 12),
                      EventLocationCard(event: event),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        'Tadbir haqida',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state is EventDetailLoading ||
                          state is EventDetailInitial)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state is EventDetailFailure) ...[
                        Text(state.message),
                        TextButton(
                          onPressed: () => context.read<EventDetailBloc>().add(
                            EventDetailRequested(widget.preview.documentId),
                          ),
                          child: const Text('Qayta urinish'),
                        ),
                      ] else
                        Text(
                          detail?.description.isNotEmpty == true
                              ? detail!.description
                              : 'Tavsif kiritilmagan.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.6),
                        ),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: .3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chipta narxi',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.isFree
                              ? 'Bepul'
                              : '${event.price.toStringAsFixed(0)} so‘m',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: (_booking || isPast)
                        ? null
                        : () async {
                            setState(() => _booking = true);
                            try {
                              final ticket = await context
                                  .read<TicketsRepository>()
                                  .reserve(event.documentId);
                              if (!context.mounted) return;
                              final viewTicket = await showBookingSuccessDialog(
                                context,
                                ticket: ticket,
                              );
                              if (!context.mounted) return;
                              if (viewTicket) {
                                // MainScreen is kept alive behind the detail route.
                                // Request the Tickets tab before popping this route.
                                MainScreen.requestTicketsTab();
                                Navigator.of(context).pop();
                              }
                            } on TicketException catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bronlashda xatolik yuz berdi.',
                                  ),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _booking = false);
                            }
                          },
                    icon: _booking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.confirmation_number_outlined),
                    label: Text(
                      isPast
                          ? 'Tadbir yakunlangan'
                          : AppText.of(context, 'reserve_place'),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _date(DateTime? date) => date == null
    ? 'Sana ko‘rsatilmagan'
    : '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} · '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _purple),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({required this.url});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      url == null || url!.isEmpty
          ? const ColoredBox(
              color: Color(0xFFEDE7FA),
              child: Icon(Icons.event, color: _purple, size: 70),
            )
          : Image.network(
              url!,
              fit: BoxFit.cover,
              cacheWidth: 1100,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFEDE7FA),
                child: Icon(Icons.image_not_supported, color: _purple),
              ),
            ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x55000000), Colors.transparent, Color(0x33000000)],
          ),
        ),
      ),
    ],
  );
}
