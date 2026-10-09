import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:worklance/core/state/app_store.dart';
import 'package:worklance/screens/marketplace/favorites_screen.dart';
import 'package:worklance/screens/marketplace/marketplace_screen.dart';
import 'package:worklance/widgets/freelancer_card.dart';
import 'package:worklance/widgets/freelancer_list_tile.dart';
import 'package:worklance/widgets/service_card.dart';

import 'widget_test.dart' show login, navLabel;

/// The vertical scrollable of the Marketplace (Home) tab.
Finder homeScrollable() => find
    .descendant(
      of: find.byType(MarketplaceScreen),
      matching: find.byType(Scrollable),
    )
    .first;

/// Drags the Home scrollable downward until [plainTarget] is built —
/// Home uses lazy slivers, so below-the-fold cards don't exist until
/// scrolled to. [plainTarget] must tolerate zero matches.
Future<void> scrollHomeUntil(
  WidgetTester tester,
  Finder plainTarget,
) async {
  final scrollable = homeScrollable();
  for (var i = 0; i < 25 && plainTarget.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -240));
    await tester.pumpAndSettle();
  }
}

/// Cards on the Home tab (other screens also mount cards, so scope first).
Finder homeCards(Type type) => find.descendant(
  of: find.byType(MarketplaceScreen),
  matching: find.byType(type),
);

/// Favorites-scoped finder — other shell tabs stay mounted in the
/// IndexedStack, so unscoped searches can match their cards too.
Finder inFavorites(Finder matching) =>
    find.descendant(of: find.byType(FavoritesScreen), matching: matching);

void main() {
  group('FavoritesController', () {
    test('toggle adds and removes ids, keeping count in sync', () {
      final favorites = FavoritesController();

      expect(favorites.isFavorite('s_flutter_app'), isFalse);
      expect(favorites.count, 0);

      favorites.toggle('s_flutter_app');
      expect(favorites.isFavorite('s_flutter_app'), isTrue);
      expect(favorites.count, 1);

      favorites.toggle('s_flutter_app');
      expect(favorites.isFavorite('s_flutter_app'), isFalse);
      expect(favorites.count, 0);
    });

    test('tracks services and freelancers independently', () {
      final favorites = FavoritesController();
      favorites.toggle('s_flutter_app');
      favorites.toggle('f_rohan');

      expect(favorites.isFavorite('s_flutter_app'), isTrue);
      expect(favorites.isFavorite('f_rohan'), isTrue);
      expect(favorites.count, 2);

      favorites.toggle('f_rohan');
      expect(favorites.isFavorite('f_rohan'), isFalse);
      expect(favorites.isFavorite('s_flutter_app'), isTrue);
    });
  });

  group('Favorites screen', () {
    testWidgets('shows empty states when nothing is saved', (tester) async {
      await login(tester);

      await tester.tap(navLabel('Favorites'));
      await tester.pumpAndSettle();

      expect(find.byType(FavoritesScreen), findsOneWidget);
      expect(find.text('No saved services yet'), findsOneWidget);

      await tester.tap(find.textContaining('Freelancers ('));
      await tester.pumpAndSettle();
      expect(find.text('No saved freelancers yet'), findsOneWidget);
    });

    testWidgets(
      'favoriting a freelancer from Home shows it in the Favorites screen '
      'and can be removed again',
      (tester) async {
        await login(tester);

        // Heart on the first Top Freelancer card on Home (below the fold,
        // so scroll until the cards are built).
        final cards = homeCards(FreelancerCard);
        await scrollHomeUntil(tester, cards);
        expect(cards, findsWidgets);

        final cardHeart = find.descendant(
          of: cards.first,
          matching: find.byTooltip('Add to favorites'),
        );
        expect(cardHeart, findsOneWidget);
        await tester.ensureVisible(cardHeart);
        await tester.pumpAndSettle();
        await tester.tap(cardHeart);
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: cards.first,
            matching: find.byTooltip('Remove from favorites'),
          ),
          findsOneWidget,
        );

        // Open Favorites → Freelancers tab.
        await tester.tap(navLabel('Favorites'));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Freelancers ('));
        await tester.pumpAndSettle();

        expect(inFavorites(find.byType(FreelancerListTile)), findsOneWidget);

        // Unfavorite from the Favorites screen itself.
        await tester.tap(inFavorites(find.byTooltip('Remove from favorites')));
        await tester.pumpAndSettle();

        expect(find.text('No saved freelancers yet'), findsOneWidget);
        expect(inFavorites(find.byType(FreelancerListTile)), findsNothing);
      },
    );

    testWidgets(
      'favoriting a service card shows it under the Services tab and keeps '
      'state consistent across screens',
      (tester) async {
        await login(tester);

        // Heart on the first service card on Home (below the fold, so
        // scroll until the cards are built).
        final cards = homeCards(ServiceCard);
        await scrollHomeUntil(tester, cards);
        expect(cards, findsWidgets);

        final serviceHeart = find.descendant(
          of: cards.first,
          matching: find.byTooltip('Add to favorites'),
        );
        expect(serviceHeart, findsOneWidget);
        await tester.ensureVisible(serviceHeart);
        await tester.pumpAndSettle();
        await tester.tap(serviceHeart);
        await tester.pumpAndSettle();

        // Navigate away and back — state must persist in the shared store.
        await tester.tap(navLabel('Favorites'));
        await tester.pumpAndSettle();

        expect(find.byType(FavoritesScreen), findsOneWidget);
        expect(inFavorites(find.byType(ServiceCard)), findsOneWidget);
        expect(find.text('No saved services yet'), findsNothing);

        // Remove it from the favorites list; empty state returns.
        await tester.tap(inFavorites(find.byTooltip('Remove from favorites')));
        await tester.pumpAndSettle();

        expect(find.text('No saved services yet'), findsOneWidget);
        expect(inFavorites(find.byType(ServiceCard)), findsNothing);
      },
    );

    testWidgets('bottom navigation still switches tabs after rename', (
      tester,
    ) async {
      await login(tester);

      await tester.tap(navLabel('Favorites'));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesScreen), findsOneWidget);

      await tester.tap(navLabel('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MarketplaceScreen), findsOneWidget);
    });
  });
}
