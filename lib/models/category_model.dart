import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String iconName;
  final int colorValue;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorValue,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'iconName': iconName,
    'colorValue': colorValue,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CategoryModel.fromJson(Map<dynamic, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    iconName: json['iconName'] as String,
    colorValue: json['colorValue'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  CategoryModel copyWith({
    String? id,
    String? name,
    String? type,
    String? iconName,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  IconData get icon => _iconMap[iconName] ?? Icons.category_outlined;

  Color get color => Color(colorValue);

  static final Map<String, IconData> _iconMap = {
    'salary': Icons.work_outline,
    'freelance': Icons.laptop_outlined,
    'investment': Icons.trending_up_outlined,
    'business': Icons.business_center_outlined,
    'gift': Icons.card_giftcard_outlined,
    'other_income': Icons.add_circle_outline,
    'food': Icons.restaurant_outlined,
    'transport': Icons.directions_car_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'entertainment': Icons.movie_outlined,
    'health': Icons.favorite_outline,
    'education': Icons.school_outlined,
    'home': Icons.home_outlined,
    'utilities': Icons.bolt_outlined,
    'subscription': Icons.subscriptions_outlined,
    'travel': Icons.flight_outlined,
    'insurance': Icons.security_outlined,
    'savings': Icons.savings_outlined,
    'other_expense': Icons.remove_circle_outline,
    'category': Icons.category_outlined,
  };

  static List<MapEntry<String, IconData>> get incomeIcons => [
    MapEntry('salary', Icons.work_outline),
    MapEntry('freelance', Icons.laptop_outlined),
    MapEntry('investment', Icons.trending_up_outlined),
    MapEntry('business', Icons.business_center_outlined),
    MapEntry('gift', Icons.card_giftcard_outlined),
    MapEntry('other_income', Icons.add_circle_outline),
  ];

  static List<MapEntry<String, IconData>> get expenseIcons => [
    MapEntry('food', Icons.restaurant_outlined),
    MapEntry('transport', Icons.directions_car_outlined),
    MapEntry('shopping', Icons.shopping_bag_outlined),
    MapEntry('entertainment', Icons.movie_outlined),
    MapEntry('health', Icons.favorite_outline),
    MapEntry('education', Icons.school_outlined),
    MapEntry('home', Icons.home_outlined),
    MapEntry('utilities', Icons.bolt_outlined),
    MapEntry('subscription', Icons.subscriptions_outlined),
    MapEntry('travel', Icons.flight_outlined),
    MapEntry('insurance', Icons.security_outlined),
    MapEntry('savings', Icons.savings_outlined),
    MapEntry('other_expense', Icons.remove_circle_outline),
  ];

  static const List<int> defaultColors = [
    0xFF6366F1,
    0xFF8B5CF6,
    0xFFEC4899,
    0xFFEF4444,
    0xFFF97316,
    0xFFEAB308,
    0xFF10B981,
    0xFF14B8A6,
    0xFF06B6D4,
    0xFF3B82F6,
    0xFF64748B,
    0xFF84CC16,
  ];
}
