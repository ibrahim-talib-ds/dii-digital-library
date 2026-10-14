class Book {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final String title;
  final String author;
  final String? bookCode;
  final String? isbn;
  final String? description;
  final String? coverUrl;
  final String? pdfUrl;
  final int? pages;
  final String? language;
  final int totalCopies;
  final int availableCopies;
  final DateTime createdAt;
  final List<Map<String, dynamic>> copyIds;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.totalCopies,
    required this.availableCopies,
    required this.createdAt,
    this.copyIds = const [],
    this.categoryId,
    this.categoryName,
    this.bookCode,
    this.isbn,
    this.description,
    this.coverUrl,
    this.pdfUrl,
    this.pages,
    this.language,
  });

  factory Book.fromJson(Map<String, dynamic> j) => Book(
        id:              j['id'] as String,
        categoryId:      j['category_id'] as String?,
        categoryName:    j['category_name'] as String?,
        title:           j['title'] as String,
        author:          j['author'] as String,
        bookCode:        j['book_code'] as String?,
        isbn:            j['isbn'] as String?,
        description:     j['description'] as String?,
        coverUrl:        j['cover_url'] as String?,
        pdfUrl:          j['pdf_url'] as String?,
        pages:           (j['pages'] as num?)?.toInt(),
        language:        j['language'] as String?,
        totalCopies:     (j['total_copies'] as num?)?.toInt() ?? 0,
        availableCopies: (j['available_copies'] as num?)?.toInt() ?? 0,
        createdAt:       DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        copyIds:         (j['copy_ids'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? const [],
      );

  bool get isAvailable => availableCopies > 0;
  bool get isLowStock  => availableCopies > 0 && availableCopies <= 2;
  bool get isOut       => availableCopies <= 0;
}
