/// A page of items with total count.
class Paginated<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;

  const Paginated({
    required this.items,
    required this.total,
    this.page = 1,
    this.size = 20,
  });

  bool get isEmpty    => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int  get pages      => (total / size).ceil();
  bool get hasMore    => page * size < total;

  factory Paginated.fromJson(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) parse,
  ) =>
      Paginated(
        items: (j['items'] as List<dynamic>)
            .map((e) => parse(e as Map<String, dynamic>))
            .toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        page:  (j['page']  as num?)?.toInt() ?? 1,
        size:  (j['size']  as num?)?.toInt() ?? 20,
      );
}
