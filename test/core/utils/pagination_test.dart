import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/core/utils/pagination.dart';

void main() {
  group('PaginationParams', () {
    test('defaults: page 1, size 20, offset 0', () {
      const p = PaginationParams();
      expect(p.page, 1);
      expect(p.pageSize, 20);
      expect(p.effectiveLimit, 20);
      expect(p.effectiveOffset, 0);
      expect(p.hasPagination, isFalse);
    });

    test('page-based offset computation', () {
      const p1 = PaginationParams(page: 1, pageSize: 25);
      const p3 = PaginationParams(page: 3, pageSize: 25);
      expect(p1.effectiveOffset, 0);
      expect(p3.effectiveOffset, 50);
    });

    test('explicit limit/offset win and flag hasPagination', () {
      const p = PaginationParams(page: 2, pageSize: 20, limit: 10, offset: 99);
      expect(p.effectiveLimit, 10);
      expect(p.effectiveOffset, 99);
      expect(p.hasPagination, isTrue);
    });

    test('copyWith keeps unpassed fields', () {
      const p = PaginationParams(page: 2, pageSize: 15);
      final q = p.copyWith(page: 5);
      expect(q.page, 5);
      expect(q.pageSize, 15);
      expect(q.effectiveOffset, 60);
    });

    test('toMap exposes effective limit/offset', () {
      const p = PaginationParams(page: 2, pageSize: 10);
      expect(p.toMap(), {'page': 2, 'pageSize': 10, 'limit': 10, 'offset': 10});
    });
  });

  group('PaginatedResult', () {
    test('hasMore false on last page', () {
      final r = PaginatedResult<int>.fromItems(
        items: const [1, 2],
        totalCount: 12,
        page: 6,
        pageSize: 2,
      );
      expect(r.hasMore, isFalse);
      expect(r.hasNext, isFalse);
      expect(r.totalPages, 6);
      expect(r.hasPrevious, isTrue);
    });

    test('hasMore true while pages remain', () {
      final r = PaginatedResult<int>.fromItems(
        items: const [1],
        totalCount: 3,
        page: 1,
        pageSize: 2,
      );
      expect(r.hasMore, isTrue);
      expect(r.hasPrevious, isFalse);
      expect(r.totalPages, 2);
    });

    test('empty first page', () {
      final r = PaginatedResult<String>.fromItems(
        items: const [],
        totalCount: 0,
        page: 1,
        pageSize: 20,
      );
      expect(r.hasMore, isFalse);
      expect(r.totalPages, 0);
      expect(r.hasPrevious, isFalse);
    });
  });
}
