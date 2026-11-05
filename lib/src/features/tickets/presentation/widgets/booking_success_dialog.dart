import 'package:flutter/material.dart';
import '../../../../core/localization/app_text.dart';
import '../../data/ticket_model.dart';

/// Returns true when the user chooses to view their ticket.
Future<bool> showBookingSuccessDialog(
  BuildContext context, {
  required TicketModel ticket,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _BookingSuccessDialog(ticket: ticket),
      ) ??
      false;
}

class _BookingSuccessDialog extends StatelessWidget {
  const _BookingSuccessDialog({required this.ticket});

  final TicketModel ticket;
  static const _accent = Color(0xFF7656D6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark
                    ? _accent.withValues(alpha: .22)
                    : _accent.withValues(alpha: .10),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 45,
                color: _accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppText.of(context, 'booking_success_title'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppText.of(
                context,
                ticket.isDemo
                    ? 'unpaid_booking_success_description'
                    : 'booking_success_description',
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (ticket.title.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: dark ? .07 : .04),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: _accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ticket.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.confirmation_number_outlined),
                label: Text(AppText.of(context, 'view_ticket')),
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppText.of(context, 'close')),
            ),
          ],
        ),
      ),
    );
  }
}
