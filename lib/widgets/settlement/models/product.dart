import 'package:flutter/material.dart';

/// Product model for settlement functionality
class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String description;
  final double? originalPrice;
  final ServiceStatus? serviceStatus;
  final DateTime? serviceTime;
  final String? statusText;
  final List<String>? tags;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.description,
    this.originalPrice,
    this.serviceStatus,
    this.serviceTime,
    this.statusText,
    this.tags,
  });

  /// Creates a copy of this product with the given fields replaced with new values
  Product copyWith({
    String? id,
    String? name,
    String? image,
    double? price,
    int? quantity,
    String? description,
    double? originalPrice,
    ServiceStatus? serviceStatus,
    DateTime? serviceTime,
    String? statusText,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      serviceTime: serviceTime ?? this.serviceTime,
      statusText: statusText ?? this.statusText,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Check if this product has a discount
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Get discount percentage
  double get discountPercentage => hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0;

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, quantity: $quantity, status: $serviceStatus}';
  }
}

/// Service status enumeration
enum ServiceStatus {
  completed,
  inProgress,
  pending,
  cancelled,
}

/// Extension for service status display
extension ServiceStatusExtension on ServiceStatus {
  String get displayName {
    switch (this) {
      case ServiceStatus.completed:
        return '服务完成';
      case ServiceStatus.inProgress:
        return '服务中';
      case ServiceStatus.pending:
        return '待服务';
      case ServiceStatus.cancelled:
        return '已取消';
    }
  }

  Color get color {
    switch (this) {
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.inProgress:
        return Colors.blue;
      case ServiceStatus.pending:
        return Colors.orange;
      case ServiceStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceStatus.completed:
        return Icons.check_circle;
      case ServiceStatus.inProgress:
        return Icons.access_time;
      case ServiceStatus.pending:
        return Icons.schedule;
      case ServiceStatus.cancelled:
        return Icons.cancel;
    }
  }
}
