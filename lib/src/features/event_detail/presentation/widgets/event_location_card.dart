import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../home/data/event_model.dart';

class EventLocationCard extends StatelessWidget {
  final EventModel event;
  const EventLocationCard({super.key, required this.event});

  Future<void> openMap(BuildContext context) async {
    final lat = event.latitude;
    final lon = event.longitude;
    final String query =
        lat != null &&
            lon != null &&
            lat >= -90 &&
            lat <= 90 &&
            lon >= -180 &&
            lon <= 180
        ? '$lat,$lon'
        : '${event.location}, ${event.city}';
    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
    if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xaritani ochib bo‘lmadi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (event.location.trim().isEmpty &&
        event.city.trim().isEmpty &&
        (event.latitude == null || event.longitude == null)) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location.isNotEmpty ? event.location : event.city,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => openMap(context),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Xaritada ko‘rish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
