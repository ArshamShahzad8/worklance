import 'package:flutter/material.dart';
/// A freelancer offering services on WORKLANCE.
class Freelancer {
  const Freelancer({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarColor,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.skills,
    this.location = 'Remote',
    this.memberSince = 'Member since 2024',
  });
  final String id;
  final String name;
  final String title;
  final Color avatarColor;
  final double rating;
  final int reviewCount;
  final String bio;
  final List<String> skills;

  /// Static mock location shown on the service cards (no GPS, mock only).
  final String location;
  final String memberSince;
  /// Initials derived from the name, e.g. "Rohan Mehta" -> "RM".
  /// Used to render the avatar without needing image assets.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
