import '../models/product.dart';

/// Service for providing mock product data
class MockDataService {
  /// Loads mock product data for demonstration purposes
  static List<Product> loadMockProducts() {
    return [
      Product(
        id: '1',
        name: '长款高端2025新款轻奢风美甲',
        image: 'https://picsum.photos/200/200?random=1',
        price: 128.00,
        originalPrice: 168.00,
        quantity: 1,
        description: '网红爆款 新款轻奢风美甲风格美甲',
        serviceStatus: ServiceStatus.completed,
        serviceTime: DateTime.now().subtract(const Duration(minutes: 5)),
        statusText: '服务65分钟',
        tags: ['粉色系', '长款高端', '90°'],
      ),
      Product(
        id: '2',
        name: '人工贴合服务',
        image: 'https://picsum.photos/200/200?random=2',
        price: 50.00,
        originalPrice: 100.00,
        quantity: 1,
        description: '专业美甲师上门服务',
        serviceStatus: ServiceStatus.inProgress,
        serviceTime: DateTime.now().subtract(const Duration(hours: 2)),
        statusText: '服务中',
        tags: ['30′'],
      ),
      Product(
        id: '3',
        name: '长款高端2025新款轻奢风美甲',
        image: 'https://picsum.photos/200/200?random=3',
        price: 128.00,
        originalPrice: 168.00,
        quantity: 1,
        description: '网红爆款 新款轻奢风美甲风格美甲',
        serviceStatus: ServiceStatus.completed,
        serviceTime: DateTime.now().subtract(const Duration(hours: 4)),
        statusText: '服务65分钟',
        tags: ['粉色系', '长款高端', '90°'],
      ),
      Product(
        id: '4',
        name: '长款高端2025新款轻奢风美甲',
        image: 'https://picsum.photos/200/200?random=4',
        price: 128.00,
        originalPrice: 168.00,
        quantity: 1,
        description: '网红爆款 新款轻奢风美甲风格美甲',
        serviceStatus: ServiceStatus.pending,
        serviceTime: DateTime.now().add(const Duration(hours: 1)),
        statusText: '待服务',
        tags: ['粉色系', '长款高端', '90°'],
      ),
      Product(
        id: '5',
        name: '[七夕礼物]La Chatelaine手部精华套装',
        image: 'https://picsum.photos/200/200?random=5',
        price: 399.00,
        originalPrice: 598.00,
        quantity: 1,
        description: '天然手部护理套装，法国制造',
        serviceStatus: ServiceStatus.pending,
        serviceTime: DateTime.now().add(const Duration(days: 1)),
        statusText: '出货中',
        tags: ['1200ml', '天然成分'],
      ),
    ];
  }

  /// Calculates total amount for a list of products
  static double calculateTotalAmount(List<Product> products) {
    return products.fold(0.0, (sum, product) => sum + (product.price * product.quantity));
  }

  /// Simulates a product search by name (for future extension)
  static List<Product> searchProducts(String query) {
    final allProducts = loadMockProducts();
    if (query.isEmpty) return allProducts;

    return allProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Simulates finding a product by ID
  static Product? findProductById(String id) {
    try {
      return loadMockProducts().firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
