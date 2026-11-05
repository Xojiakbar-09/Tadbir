import 'package:flutter/material.dart';
import '../../../home/data/event_filters.dart';
import '../../../home/data/event_model.dart';

class FilterSheet extends StatefulWidget {
  final EventFilters initial;
  final List<CategoryModel> categories;
  const FilterSheet({
    super.key,
    required this.initial,
    required this.categories,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late EventFilters filters;
  late final TextEditingController city;

  @override
  void initState() {
    super.initState();
    filters = widget.initial;
    city = TextEditingController(text: filters.city ?? '');
  }

  @override
  void dispose() {
    city.dispose();
    super.dispose();
  }

  Future<void> pickDates() async {
    final now = DateTime.now();
    final chosen = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDateRange: filters.from != null && filters.to != null
          ? DateTimeRange(start: filters.from!, end: filters.to!)
          : null,
    );
    if (chosen == null || !mounted) return;
    setState(
      () => filters = filters.copyWith(
        from: chosen.start,
        to: DateTime(
          chosen.end.year,
          chosen.end.month,
          chosen.end.day,
          23,
          59,
          59,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Filtrlar', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    filters = EventFilters(search: widget.initial.search);
                    city.clear();
                  }),
                  child: const Text('Tozalash'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Kategoriya'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Hammasi'),
                  selected: filters.categorySlug == null,
                  onSelected: (_) => setState(
                    () => filters = filters.copyWith(clearCategory: true),
                  ),
                ),
                ...widget.categories.map(
                  (c) => ChoiceChip(
                    label: Text(c.name),
                    selected: filters.categorySlug == c.slug,
                    onSelected: (_) => setState(
                      () => filters = filters.copyWith(categorySlug: c.slug),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: city,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Shahar',
                hintText: 'Masalan, Toshkent',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Narx'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Barchasi'),
                  selected: filters.isFree == null,
                  onSelected: (_) => setState(
                    () => filters = filters.copyWith(clearPrice: true),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Bepul'),
                  selected: filters.isFree == true,
                  onSelected: (_) =>
                      setState(() => filters = filters.copyWith(isFree: true)),
                ),
                ChoiceChip(
                  label: const Text('Pullik'),
                  selected: filters.isFree == false,
                  onSelected: (_) =>
                      setState(() => filters = filters.copyWith(isFree: false)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: pickDates,
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                filters.from == null
                    ? 'Sana oralig‘i'
                    : '${filters.from!.day}.${filters.from!.month}.${filters.from!.year} — '
                          '${filters.to!.day}.${filters.to!.month}.${filters.to!.year}',
              ),
            ),
            if (filters.from != null)
              TextButton(
                onPressed: () => setState(
                  () => filters = filters.copyWith(clearDates: true),
                ),
                child: const Text('Sanani tozalash'),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  filters.copyWith(
                    city: city.text.trim().isEmpty ? null : city.text.trim(),
                    clearCity: city.text.trim().isEmpty,
                  ),
                ),
                child: const Text('Natijalarni ko‘rsatish'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
