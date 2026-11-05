import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/localization/app_text.dart';
import '../../data/ticket_model.dart';
import '../cubit/tickets_cubit.dart';

const _purple = Color(0xFF7656D6);

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TicketsCubit>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<TicketsCubit>().refresh(),
        child: BlocBuilder<TicketsCubit, TicketsState>(
          builder: (context, state) {
            // No archive tab. Removed or expired tickets do not clutter this page.
            final tickets = state.tickets
                .where((t) => t.status == 'reserved' && !t.isPast)
                .toList();
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TADBIR · GO',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppText.of(context, 'my_tickets'),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppText.of(context, 'tickets_intro'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.loading && state.tickets.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null && state.tickets.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyTickets(
                      message: state.error!,
                      onRetry: () => context.read<TicketsCubit>().refresh(),
                    ),
                  )
                else if (tickets.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyTickets(
                      message: AppText.of(context, 'no_active_tickets'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 136),
                    sliver: SliverList.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _TicketCard(ticket: tickets[index]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const _TicketCard({required this.ticket});

  Future<void> _delete(BuildContext context) async {
    // Do not call AppText.of() here: it uses context.watch() and crashes in
    // event handlers. read() obtains translations without listening.
    final title = AppText.read(context, 'delete_ticket');
    final question = AppText.read(context, 'delete_ticket_confirmation');
    final cancelLabel = AppText.read(context, 'close');
    final deleteLabel = AppText.read(context, 'delete');
    final doneMessage = AppText.read(context, 'ticket_deleted');
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<TicketsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await cubit.cancel(ticket.documentId);
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(doneMessage)));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final displayDate = ticket.startDate == null
        ? '—'
        : '${ticket.startDate!.day.toString().padLeft(2, '0')}.${ticket.startDate!.month.toString().padLeft(2, '0')}.${ticket.startDate!.year}  ·  ${ticket.startDate!.hour.toString().padLeft(2, '0')}:${ticket.startDate!.minute.toString().padLeft(2, '0')}';

    return Material(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 178,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty)
                    Image.network(
                      ticket.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _CoverFallback(),
                    )
                  else
                    const _CoverFallback(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0xD9000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 17,
                    child: Text(
                      ticket.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _DetailLabel(
                      label: AppText.of(context, 'ticket_date'),
                      value: displayDate,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailLabel(
                      label: AppText.of(context, 'ticket_place'),
                      value: ticket.location,
                      icon: Icons.place_outlined,
                    ),
                  ),
                ],
              ),
            ),
            if (ticket.isDemo)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  AppText.of(context, 'unpaid_reservation_notice'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else if (ticket.ticketCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: QrImageView(
                      data: ticket.ticketCode,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: theme.dividerColor.withValues(alpha: .5),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.ios_share_outlined, size: 18),
                      label: Text(AppText.of(context, 'share_event')),
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          text:
                              '${ticket.title}\n$displayDate\n${ticket.location}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(AppText.of(context, 'delete')),
                      onPressed: () => _delete(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: dark
                            ? const Color(0xFF6E4FC8)
                            : _purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF6F53BA), Color(0xFF28233C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        Icons.confirmation_number_outlined,
        size: 62,
        color: Color(0x77FFFFFF),
      ),
    ),
  );
}

class _DetailLabel extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DetailLabel({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: _purple, size: 18),
      const SizedBox(width: 7),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _EmptyTickets extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _EmptyTickets({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: _purple,
              size: 36,
            ),
          ),
          const SizedBox(height: 15),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(AppText.of(context, 'retry')),
            ),
        ],
      ),
    ),
  );
}
