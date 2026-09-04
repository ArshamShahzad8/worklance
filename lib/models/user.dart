import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The logged-in user profile shown across the app (greeting, profile tab,
/// and — once [isFreelancer] is true — the freelancer-facing screens added
/// in Week 3: My Freelancer Profile, My Services and Create Service).
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.title = 'Client',
    this.location = 'Remote',
    this.bio = '',
    this.skills = const [],
    this.avatarColor = AppColors.primary,
    this.isFreelancer = false,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.completedJobs = 0,
    this.memberSince = 'Member since 2026',
  });

  final String name;
  final String email;
  final String title;
  final String location;

  /// Freelancer bio shown on the Freelancer Profile screen.
  final String bio;

  /// Skills shown as chips on the Freelancer Profile screen.
  final List<String> skills;

  /// Avatar background color, consistent across Profile & Freelancer Profile.
  final Color avatarColor;

  /// Whether this user has completed their freelancer profile. Gates access
  /// to My Services / Create Service until a bio + at least one skill exist.
  final bool isFreelancer;

  final double rating;
  final int reviewCount;
  final int completedJobs;
  final String memberSince;

  /// First word of the name, used for the personalized greeting.
  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
  }

  /// Initials used for the avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? title,
    String? location,
    String? bio,
    List<String>? skills,
    Color? avatarColor,
    bool? isFreelancer,
    double? rating,
    int? reviewCount,
    int? completedJobs,
    String? memberSince,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      title: title ?? this.title,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      avatarColor: avatarColor ?? this.avatarColor,
      isFreelancer: isFreelancer ?? this.isFreelancer,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedJobs: completedJobs ?? this.completedJobs,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
