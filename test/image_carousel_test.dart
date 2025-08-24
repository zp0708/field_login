import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field_login/widgets/image_carousel/image_carousel.dart';
import 'package:field_login/widgets/image_carousel/image_carousel_controller.dart';
import 'package:field_login/widgets/image_carousel/models/carousel_options.dart';

void main() {
  group('ImageCarousel Infinite Scroll Tests', () {
    testWidgets('should support left scrolling in infinite scroll mode', (WidgetTester tester) async {
      final controller = ImageCarouselController();
      final images = [
        'https://picsum.photos/400/200?random=1',
        'https://picsum.photos/400/200?random=2',
        'https://picsum.photos/400/200?random=3',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageCarousel(
              images: images,
              controller: controller,
              options: const ImageCarouselOptions(
                infiniteScroll: true,
                height: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should be at index 0
      expect(controller.currentIndex, equals(0));

      // Test left scrolling (previous page)
      controller.previousPage();
      await tester.pumpAndSettle();

      // Should wrap to last image (index 2)
      expect(controller.currentIndex, equals(2));

      // Test right scrolling (next page)
      controller.nextPage();
      await tester.pumpAndSettle();

      // Should wrap back to first image (index 0)
      expect(controller.currentIndex, equals(0));
    });

    testWidgets('should handle positive modulo correctly for negative indices', (WidgetTester tester) async {
      final controller = ImageCarouselController();
      final images = [
        'https://picsum.photos/400/200?random=1',
        'https://picsum.photos/400/200?random=2',
        'https://picsum.photos/400/200?random=3',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageCarousel(
              images: images,
              controller: controller,
              options: const ImageCarouselOptions(
                infiniteScroll: true,
                height: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set to index 0 initially
      controller.setCurrentIndex(0);
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(0));

      // Go to previous (should be last item)
      controller.previousPage();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(2));

      // Go to previous again
      controller.previousPage();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(1));

      // Go to previous again
      controller.previousPage();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, equals(0));
    });

    testWidgets('should support gesture-based left scrolling', (WidgetTester tester) async {
      final controller = ImageCarouselController();
      final images = [
        'https://picsum.photos/400/200?random=1',
        'https://picsum.photos/400/200?random=2',
        'https://picsum.photos/400/200?random=3',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageCarousel(
              images: images,
              controller: controller,
              options: const ImageCarouselOptions(
                infiniteScroll: true,
                enableGestureControl: true,
                height: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the PageView widget
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      // Initially should be at index 0
      expect(controller.currentIndex, equals(0));

      // Swipe right (shows previous page in infinite scroll)
      await tester.drag(pageViewFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Should wrap to last image (index 2)
      expect(controller.currentIndex, equals(2));

      // Swipe left (shows next page)
      await tester.drag(pageViewFinder, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Should go back to first image (index 0)
      expect(controller.currentIndex, equals(0));
    });
  });
}
