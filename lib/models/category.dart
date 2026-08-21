import 'package:flutter/material.dart';

/// A marketplace category (e.g. Web Development, UI/UX Design).
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  final String id;
  final String name;
  final IconData icon;
  final String description;
}
