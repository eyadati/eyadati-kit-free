class QueryOptimizer {
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int recommendedLimit = 50;

  static int sanitizeLimit(int? limit) {
    if (limit == null || limit <= 0) {
      return defaultPageSize;
    }
    if (limit > maxPageSize) {
      return maxPageSize;
    }
    return limit;
  }

  static int sanitizeOffset(int? offset) {
    if (offset == null || offset < 0) {
      return 0;
    }
    return offset;
  }

  static int calculateOffset(int page, int limit) {
    if (page <= 0) page = 1;
    return (page - 1) * sanitizeLimit(limit);
  }

  static List<String> optimizeSelectColumns(List<String> neededColumns, List<String> availableColumns) {
    if (neededColumns.isEmpty) {
      return availableColumns;
    }
    return neededColumns.where((col) => availableColumns.contains(col)).toList();
  }

  static bool shouldUsePagination(int estimatedCount) {
    return estimatedCount > recommendedLimit;
  }
}
