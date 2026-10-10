import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? image;
  final int itemCount;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.image,
    this.itemCount = 0,
  });
}
