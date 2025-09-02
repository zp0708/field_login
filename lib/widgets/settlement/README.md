# Settlement 结算单组件 - 重构版

## 概述

Settlement 是一个功能完整的结算单页面组件，采用模块化架构设计，将不同功能代码分离到独立文件中，提高代码的可维护性和可扩展性。该组件使用 Riverpod 进行状态管理，提供良好的用户体验和现代化的 UI 设计。

## 📁 项目结构

```
lib/widgets/settlement/
├── settlement.dart                    # 主导出文件（Barrel File）
├── settlement_page.dart               # 主页面组件
├── README.md                          # 项目文档
│
├── models/                            # 数据模型
│   ├── product.dart                   # 商品模型
│   ├── settlement_status.dart         # 结算状态枚举及扩展
│   └── settlement_state.dart          # 结算状态管理
│
├── services/                          # 业务服务层
│   ├── mock_data_service.dart         # 模拟数据服务
│   └── payment_service.dart           # 支付服务
│
├── notifiers/                         # 状态管理层
│   └── settlement_notifier.dart       # 结算状态通知器
│
├── providers/                         # Riverpod 提供者
│   └── settlement_providers.dart      # 所有相关提供者
│
└── components/                        # UI 组件
    ├── status_indicator.dart          # 状态指示器
    ├── selection_controls.dart        # 选择控制器
    ├── product_item.dart              # 商品项组件
    └── payment_section.dart           # 支付区域组件
```

## 主要特性

### 🎯 核心功能
- **商品多选**: 支持单独选择或批量选择商品
- **状态管理**: 使用 Riverpod 进行高效的状态管理
- **双状态支持**: 创建状态和未支付状态
- **实时计算**: 动态计算选中商品的总价
- **支付控制**: 根据选择状态控制支付按钮的可用性

### 🎨 UI/UX 特性
- **现代化设计**: 清爽的卡片式设计
- **状态指示器**: 清晰显示当前结算单状态
- **全选控制**: 便捷的全选/取消全选功能
- **商品展示**: 图片、名称、价格、数量完整展示
- **错误处理**: 优雅的错误信息展示和关闭功能
- **加载状态**: 支付过程中的加载指示器

### 📱 交互特性
- **点击选择**: 点击商品行或复选框进行选择
- **状态切换**: 顶部按钮快速切换状态
- **支付处理**: 模拟真实支付流程
- **错误恢复**: 支付失败后可重试

## 技术实现

### 状态管理架构

```dart
// 使用 Riverpod StateNotifier 进行状态管理
final settlementProvider = StateNotifierProvider<SettlementNotifier, SettlementState>((ref) {
  return SettlementNotifier();
});
```

### 数据模型

#### Product 商品模型
```dart
class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String description;
}
```

#### SettlementState 结算状态
```dart
class SettlementState {
  final SettlementStatus status;        // 结算单状态
  final List<Product> products;         // 商品列表
  final Set<String> selectedProductIds; // 已选商品ID集合
  final double totalAmount;             // 总金额
  final bool isLoading;                // 加载状态
  final String? errorMessage;          // 错误信息
}
```

#### SettlementStatus 状态枚举
```dart
enum SettlementStatus {
  created, // 创建状态
  unpaid,  // 未支付状态
}
```

### 核心方法

#### 商品选择管理
```dart
// 切换单个商品选择状态
void toggleProductSelection(String productId);

// 全选商品
void selectAllProducts();

// 清空所有选择
void clearAllSelections();
```

#### 状态管理
```dart
// 更改结算单状态
void changeStatus(SettlementStatus newStatus);

// 处理支付
Future<void> processPayment();
```

### 计算属性

```dart
// 获取已选商品
List<Product> get selectedProducts;

// 检查是否有选中商品
bool get hasSelectedProducts;

// 计算选中商品总价
double get selectedTotalPrice;
```

## 组件结构

### UI 组件层次
```
SettlementPage
├── AppBar (标题 + 状态切换)
├── StatusIndicator (状态指示器)
├── SelectionControls (全选控制)
├── ProductList (商品列表)
│   └── ProductItem (单个商品)
│       ├── Checkbox (选择框)
│       ├── ProductImage (商品图片)
│       └── ProductDetails (商品信息)
└── BottomPaymentSection (底部支付区域)
    ├── ErrorMessage (错误信息)
    ├── TotalPrice (总价显示)
    └── PaymentButton (支付按钮)
```

## 使用方法

### 基础用法

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/widgets/settlement/settlement.dart';

// 在应用根部添加 ProviderScope
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// 使用结算单页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SettlementPage(),
  ),
);
```

### 演示页面

```dart
import 'package:your_app/demos/settlement_demo.dart';

// 使用演示页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SettlementDemo(),
  ),
);
```

## 自定义配置

### 修改模拟数据

在 `SettlementNotifier._loadMockData()` 方法中修改商品数据：

```dart
void _loadMockData() {
  final mockProducts = [
    const Product(
      id: '1',
      name: '自定义商品',
      image: '图片URL',
      price: 99.9,
      quantity: 1,
      description: '商品描述',
    ),
    // 添加更多商品...
  ];
}
```

### 自定义样式

组件支持通过修改 `_buildXxx` 方法来自定义样式：

- `_buildStatusIndicator`: 状态指示器样式
- `_buildSelectionControls`: 选择控制样式
- `_buildProductList`: 商品列表样式
- `_buildBottomPaymentSection`: 底部支付区域样式

## 依赖要求

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  cached_network_image: ^3.3.1  # 用于网络图片缓存
```

## 文件结构

```
lib/widgets/settlement/
└── settlement.dart                 # 结算单组件主文件

lib/demos/
└── settlement_demo.dart           # 结算单演示页面
```

## 注意事项

1. **状态管理**: 确保应用根部包含 `ProviderScope`
2. **网络图片**: 组件使用网络图片，请确保网络连接正常
3. **支付模拟**: 当前支付功能为模拟实现，实际项目中需要集成真实支付SDK
4. **错误处理**: 组件包含随机错误模拟，用于演示错误处理流程

## 扩展建议

1. **持久化**: 可集成本地存储保存选择状态
2. **动画**: 添加选择和状态切换的动画效果
3. **国际化**: 添加多语言支持
4. **主题**: 支持深色模式和自定义主题
5. **优化**: 大量商品时可考虑虚拟滚动优化

## 更新日志

### v1.0.0 (2025-09-01)
- ✨ 初始版本发布
- ✅ 支持商品多选功能
- ✅ 集成 Riverpod 状态管理
- ✅ 实现状态切换和支付处理
- ✅ 完整的 UI 设计和交互
- ✅ 错误处理和加载状态
- ✅ 演示页面和文档