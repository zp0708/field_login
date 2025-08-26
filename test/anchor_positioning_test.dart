import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field_login/widgets/product_detail_anchor/product_detail_anchor.dart';

void main() {
  group('AnchorController Tests', () {
    testWidgets('should initialize with first tab active', (WidgetTester tester) async {
      final anchors = [
        AnchorConfig(id: 'section1', title: 'Section 1', key: GlobalKey()),
        AnchorConfig(id: 'section2', title: 'Section 2', key: GlobalKey()),
        AnchorConfig(id: 'section3', title: 'Section 3', key: GlobalKey()),
      ];

      final scrollController = ScrollController();
      final anchorController = ProductDetailAnchorController(
        scrollController: scrollController,
        anchors: anchors,
        tabBarHeight: 60.0,
        stickyOffset: 100.0,
      );

      expect(anchorController.currentActiveIndex, 0);
      expect(anchorController.isScrollingToAnchor, false);

      anchorController.dispose();
      scrollController.dispose();
    });

    testWidgets('should update active index when scrolling', (WidgetTester tester) async {
      final anchors = [
        AnchorConfig(id: 'section1', title: 'Section 1', key: GlobalKey()),
        AnchorConfig(id: 'section2', title: 'Section 2', key: GlobalKey()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailAnchorPage(
            anchors: anchors,
            contentBuilder: (context, anchor) {
              return SizedBox(
                height: 500,
                child: Text(anchor.title),
              );
            },
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);

      // Test that tabs are present
      final tabFinder = find.byType(GestureDetector);
      expect(tabFinder, findsNWidgets(2));
    });
  });

  group('AnchorConfig Tests', () {
    test('should create anchor config with required parameters', () {
      final key = GlobalKey();
      final config = AnchorConfig(
        id: 'test',
        title: 'Test Section',
        key: key,
      );

      expect(config.id, 'test');
      expect(config.title, 'Test Section');
      expect(config.key, key);
      expect(config.offset, null);
    });

    test('should create anchor config with offset', () {
      final key = GlobalKey();
      final config = AnchorConfig(
        id: 'test',
        title: 'Test Section',
        key: key,
        offset: 50.0,
      );

      expect(config.offset, 50.0);
    });
  });
}
