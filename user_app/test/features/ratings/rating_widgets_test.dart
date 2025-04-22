import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/ratings/application/ratings_notifier.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_stars.dart';
import 'package:user_app/features/ratings/presentation/widgets/interactive_rating_stars.dart';
import 'package:user_app/features/ratings/presentation/widgets/rating_summary.dart';

import 'rating_widgets_test.mocks.dart';

@GenerateMocks([RatingsNotifier])
void main() {
  group('RatingStars Widget', () {
    testWidgets('should display correct number of stars', (WidgetTester tester) async {
      // Arrange
      const rating = 3.5;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStars(rating: rating),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.star), findsNWidgets(3)); // 3 full stars
      expect(find.byIcon(Icons.star_half), findsOneWidget); // 1 half star
      expect(find.byIcon(Icons.star_border), findsOneWidget); // 1 empty star
    });
    
    testWidgets('should display rating number when showNumber is true', (WidgetTester tester) async {
      // Arrange
      const rating = 4.2;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStars(
              rating: rating,
              showNumber: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('4.2'), findsOneWidget);
    });
    
    testWidgets('should not display rating number when showNumber is false', (WidgetTester tester) async {
      // Arrange
      const rating = 4.2;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStars(
              rating: rating,
              showNumber: false,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('4.2'), findsNothing);
    });
    
    testWidgets('should use custom size and colors', (WidgetTester tester) async {
      // Arrange
      const rating = 3.0;
      const size = 30.0;
      const color = Colors.red;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingStars(
              rating: rating,
              size: size,
              color: color,
            ),
          ),
        ),
      );
      
      // Assert
      final starIcon = tester.widget<Icon>(find.byIcon(Icons.star).first);
      expect(starIcon.size, equals(size));
      expect(starIcon.color, equals(color));
    });
  });
  
  group('InteractiveRatingStars Widget', () {
    testWidgets('should display initial rating', (WidgetTester tester) async {
      // Arrange
      const initialRating = 3.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveRatingStars(
              initialRating: initialRating,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.star), findsNWidgets(3)); // 3 full stars
      expect(find.byIcon(Icons.star_border), findsNWidgets(2)); // 2 empty stars
    });
    
    testWidgets('should update rating when tapping on stars', (WidgetTester tester) async {
      // Arrange
      const initialRating = 3.0;
      double newRating = 0.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveRatingStars(
              initialRating: initialRating,
              onRatingChanged: (rating) {
                newRating = rating;
              },
            ),
          ),
        ),
      );
      
      // Tap on the 5th star
      await tester.tap(find.byIcon(Icons.star_border).last);
      await tester.pump();
      
      // Assert
      expect(newRating, equals(5.0));
      expect(find.byIcon(Icons.star), findsNWidgets(5)); // 5 full stars
      expect(find.byIcon(Icons.star_border), findsNothing); // 0 empty stars
    });
  });
  
  group('RatingSummaryWidget', () {
    testWidgets('should display average rating and distribution', (WidgetTester tester) async {
      // Arrange
      const averageRating = 4.2;
      const totalRatings = 10;
      final ratingDistribution = {
        5: 5, // 5 stars: 5 ratings
        4: 2, // 4 stars: 2 ratings
        3: 1, // 3 stars: 1 rating
        2: 1, // 2 stars: 1 rating
        1: 1, // 1 star: 1 rating
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingSummaryWidget(
              averageRating: averageRating,
              totalRatings: totalRatings,
              ratingDistribution: ratingDistribution,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('4.2'), findsOneWidget);
      expect(find.text('10 تقييمات'), findsOneWidget);
      
      // Check distribution bars
      // Note: This is a simplified test. In a real test, you might want to verify
      // the actual sizes of the bars, but that's more complex.
      expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
    });
  });
}
