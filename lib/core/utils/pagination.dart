class PaginationParams {
  final int page;
  final int pageSize;
  final int? limit;
  final int? offset;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.limit,
    this.offset,
  });

  int get effectiveLimit => limit ?? pageSize;
  int get effectiveOffset => offset ?? (page - 1) * effectiveLimit;

  bool get hasPagination => limit != null || offset != null;

  PaginationParams copyWith({
    int? page,
    int? pageSize,
    int? limit,
    int? offset,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'pageSize': pageSize,
      'limit': effectiveLimit,
      'offset': effectiveOffset,
    };
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedResult.fromItems({
    required List<T> items,
    required int totalCount,
    required int page,
    required int pageSize,
  }) {
    return PaginatedResult(
      items: items,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
      hasMore: (page * pageSize) < totalCount,
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasPrevious => page > 1;
  bool get hasNext => hasMore;
}
