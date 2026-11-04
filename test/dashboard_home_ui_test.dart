import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rewardbrick_app/screens/dashboard_screen.dart';

void main() {
  testWidgets('dashboard poster displays its configured image', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 160,
            child: BannerCard(
              title: 'Featured rewards',
              subtitle: 'Explore new offers',
              icon: Icons.card_giftcard_rounded,
              accent: Colors.blue,
              imageUrl: 'https://cdn.example.com/poster.jpg',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets(
      'dashboard home tab shows earning categories and a leaderboard entry point',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Choose your earning lane'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('View'), findsWidgets);
    expect(find.text('Tap View to see the current rankings.'), findsOneWidget);
    expect(find.text('Susanth Founder'), findsNothing);
    expect(find.text('Playtime'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('PREMIUM SURVEYS'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(RefreshIndicator).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('PREMIUM SURVEYS'), findsOneWidget);
    expect(find.text('FUN GAMES'), findsOneWidget);
    expect(find.text('Surveys'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
  });
}
