import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/subscription.dart';

void main() {
  group('Subscription Entity', () {
    final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

    test(
      'calculates normalized monthly and annual costs for monthly subscription',
      () {
        final Subscription sub = Subscription(
          id: 'sub-1',
          name: 'Netflix',
          amountCents: 1599, // $15.99 / month
          frequency: RecurrenceFrequency.monthly,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          billingDay: 15,
          nextDueDate: now,
          createdAt: now,
          updatedAt: now,
        );

        expect(sub.monthlyEquivalentCents, equals(1599));
        expect(sub.annualProjectionCents, equals(19188)); // 1599 * 12
      },
    );

    test(
      'calculates normalized monthly and annual costs for weekly subscription',
      () {
        final Subscription sub = Subscription(
          id: 'sub-2',
          name: 'Personal Training',
          amountCents: 3000, // $30.00 / week
          frequency: RecurrenceFrequency.weekly,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          billingDay: 1,
          nextDueDate: now,
          createdAt: now,
          updatedAt: now,
        );

        // (3000 * 52) ~/ 12 = 156000 ~/ 12 = 13000
        expect(sub.monthlyEquivalentCents, equals(13000));
        expect(sub.annualProjectionCents, equals(156000));
      },
    );

    test(
      'calculates normalized monthly and annual costs for biweekly subscription',
      () {
        final Subscription sub = Subscription(
          id: 'sub-3',
          name: 'Cleaning Service',
          amountCents: 5000, // $50.00 / biweekly
          frequency: RecurrenceFrequency.biweekly,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          billingDay: 1,
          nextDueDate: now,
          createdAt: now,
          updatedAt: now,
        );

        // (5000 * 26) ~/ 12 = 130000 ~/ 12 = 10833
        expect(sub.monthlyEquivalentCents, equals(10833));
        expect(sub.annualProjectionCents, equals(129996));
      },
    );

    test(
      'calculates normalized monthly and annual costs for annual subscription',
      () {
        final Subscription sub = Subscription(
          id: 'sub-4',
          name: 'Amazon Prime',
          amountCents: 13900, // $139.00 / year
          frequency: RecurrenceFrequency.annual,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          billingDay: 1,
          nextDueDate: now,
          createdAt: now,
          updatedAt: now,
        );

        // 13900 ~/ 12 = 1158
        expect(sub.monthlyEquivalentCents, equals(1158));
        expect(sub.annualProjectionCents, equals(13896));
      },
    );

    test('validates billingDay and amount bounds', () {
      expect(
        () => Subscription(
          id: 'sub-err-1',
          name: 'Invalid Day',
          amountCents: 1000,
          frequency: RecurrenceFrequency.monthly,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          billingDay: 0,
          nextDueDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Subscription(
          id: 'sub-err-2',
          name: 'Invalid Amount',
          amountCents: 0,
          frequency: RecurrenceFrequency.monthly,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          billingDay: 15,
          nextDueDate: now,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
