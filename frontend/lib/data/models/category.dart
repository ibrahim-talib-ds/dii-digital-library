class Category {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    this.description,
    this.icon,
    this.color,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id:          j['id'] as String,
        slug:        j['slug'] as String,
        name:        j['name'] as String,
        description: j['description'] as String?,
        icon:        j['icon'] as String?,
        color:       j['color'] as String?,
        imageUrl:    j['image_url'] as String?,
        sortOrder:   (j['sort_order'] as num?)?.toInt() ?? 0,
        isActive:    j['is_active'] as bool? ?? true,
        createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      );
}
