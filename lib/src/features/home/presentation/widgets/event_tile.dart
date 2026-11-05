import 'package:flutter/material.dart';
import '../../../../core/localization/app_text.dart';
import '../../data/event_model.dart';

const lavender = Color(0xFF7656D6);

class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    this.featured = false,
    this.heroTag,
  });
  final EventModel event;
  final bool featured;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final muted = dark ? const Color(0xFFB1AEBB) : const Color(0xFF797782);
    final date = event.startDate;
    final formatted = date == null
        ? AppText.of(context, 'date_not_set')
        : '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')} · '
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final price = event.isFree
        ? AppText.of(context, 'free')
        : '${event.price.toStringAsFixed(0)} so‘m';
    final image = event.imageUrl == null
        ? const _Placeholder()
        : Image.network(
            event.imageUrl!,
            fit: BoxFit.cover,
            cacheWidth: featured ? 1000 : 380,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, _, _) => const _Placeholder(),
          );
    final tag = heroTag ?? 'event-cover-${event.documentId}';

    if (featured) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(tag: tag, child: image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000),
                    Color(0x11000000),
                    Color(0xD9000000),
                  ],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 17,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 210),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: .38),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .22),
                  ),
                ),
                child: Text(
                  event.category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 19,
              right: 19,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$formatted  •  ${event.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .90),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_outward_rounded,
                          color: Color(0xFF17171B),
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: dark ? const Color(0xFF242429) : Colors.white,
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .09)
              : Colors.black.withValues(alpha: .055),
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: tag,
            child: SizedBox(width: 116, height: 118, child: image),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 13, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: lavender,
                      letterSpacing: .9,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$formatted · ${event.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: dark ? const Color(0xFFC4B2FF) : lavender,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFDDD7E9),
    child: Center(
      child: Icon(Icons.event_rounded, size: 38, color: Color(0xFF7656D6)),
    ),
  );
}
