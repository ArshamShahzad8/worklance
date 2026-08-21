import 'category.dart';
import 'freelancer.dart';
/// A service listing on the WORKLANCE marketplace.
/// A service belongs to one [Category] and is offered by one [Freelancer].
/// Rating and review count come from the freelancer, so the same freelancer
/// carries the same reputation across all their services.
class Service {
  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.freelancer,
    required this.price,
    required this.deliveryDays,
    required this.skills,
    this.featured = false,
  });

  final String id;
  final String title;
  final String description;
  final Category category;
  final Freelancer freelancer;
  final double price;
  final int deliveryDays;
  final List<String> skills;
  final bool featured;

  double get rating => freelancer.rating;
  int get reviewCount => freelancer.reviewCount;
}
