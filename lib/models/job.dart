import 'package:flutter/material.dart';

import 'category.dart';

/// How a job's budget is structured.
enum BudgetType {
  fixed('Fixed Price'),
  hourly('Hourly Rate');

  const BudgetType(this.label);
  final String label;
}

/// Experience level a client is looking for.
enum ExperienceLevel {
  entry('Entry Level'),
  intermediate('Intermediate'),
  expert('Expert');

  const ExperienceLevel(this.label);
  final String label;
}

/// The client who posted a [Job].
///
/// Kept separate from [Freelancer] because clients and freelancers surface
/// different stats (jobs posted / total spent vs. completed jobs / rating
/// as a service provider). A user of the app can be both — see
/// `UserController.asClient` and `UserController.asFreelancer`.
class JobClient {
  const JobClient({
    required this.id,
    required this.name,
    required this.avatarColor,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.location = 'Remote',
    this.jobsPosted = 1,
    this.totalSpent = 0,
    this.paymentVerified = true,
    this.memberSince = 'Member since 2026',
  });

  final String id;
  final String name;
  final Color avatarColor;
  final double rating;
  final int reviewCount;
  final String location;
  final int jobsPosted;
  final double totalSpent;
  final bool paymentVerified;
  final String memberSince;
}

/// A job posting on the WORKLANCE job marketplace.
///
/// Read from [JobRepository]/`JobsController` — never construct mock jobs
/// directly inside a screen, so swapping in a real API later only means
/// changing the repository/controller, not the UI.
class Job {
  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.budgetType,
    required this.budgetMin,
    required this.budgetMax,
    required this.experienceLevel,
    required this.duration,
    required this.postedAt,
    required this.proposalsCount,
    required this.client,
    this.location = 'Remote',
    this.featured = false,
  });

  final String id;
  final String title;
  final String description;
  final Category category;
  final List<String> skills;
  final BudgetType budgetType;

  /// For [BudgetType.fixed] a single amount is represented by
  /// `budgetMin == budgetMax`. For [BudgetType.hourly] these are the low/high
  /// end of the hourly rate range.
  final double budgetMin;
  final double budgetMax;
  final ExperienceLevel experienceLevel;

  /// Human-readable project length, e.g. "1 to 3 months".
  final String duration;
  final DateTime postedAt;
  final int proposalsCount;
  final JobClient client;
  final String location;
  final bool featured;

  /// Formatted budget, e.g. `$500 - $1,200` or `$15 - $30/hr`.
  String get budgetLabel {
    final suffix = budgetType == BudgetType.hourly ? '/hr' : '';
    if (budgetMin == budgetMax) {
      return '\$${_formatAmount(budgetMin)}$suffix';
    }
    return '\$${_formatAmount(budgetMin)} - \$${_formatAmount(budgetMax)}$suffix';
  }

  static String _formatAmount(double value) {
    final rounded = value.round();
    final str = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  Job copyWith({int? proposalsCount}) {
    return Job(
      id: id,
      title: title,
      description: description,
      category: category,
      skills: skills,
      budgetType: budgetType,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      experienceLevel: experienceLevel,
      duration: duration,
      postedAt: postedAt,
      proposalsCount: proposalsCount ?? this.proposalsCount,
      client: client,
      location: location,
      featured: featured,
    );
  }
}
