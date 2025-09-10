# Using GenericRefreshList with Existing Models

This guide shows you how to integrate the `GenericRefreshList` component with your existing models or models that already inherit from other classes.

## The Challenge

You have existing models that:
- Already extend another base class
- Have complex inheritance hierarchies  
- Can't be easily modified to extend `BaseListModel`
- Need to maintain their current structure

## Solutions Overview

We provide **3 flexible approaches** to handle different scenarios:

| Approach | Best For | Pros | Cons |
|----------|----------|------|------|
| **Mixin** | Models with existing inheritance | Non-intrusive, flexible | Requires implementing list properties |
| **ListStateMixin** | Simple existing models | Minimal code, default implementations | Less control over properties |
| **Wrapper Pattern** | Complex models you can't change | Zero changes to existing model | Extra wrapper layer |

---

## Approach 1: Using GenericListMixin

**Best for:** Models that already extend another class

### Example: Existing Model with Inheritance

```dart
// Your existing base class
abstract class BaseApiModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BaseApiModel({required this.id, required this.createdAt, required this.updatedAt});
}

// Your existing User model
class User extends BaseApiModel {
  final String name;
  final String email;
  
  User({
    required super.id,
    required super.createdAt, 
    required super.updatedAt,
    required this.name,
    required this.email,
  });
}

// ✅ Solution: Add mixin to your state class
class UserPageState extends BaseApiModel with GenericListMixin<User> {
  final List<User> users;
  
  // Required by GenericListMixin
  @override
  final int page;
  @override  
  final bool hasMore;
  @override
  final bool isLoading;
  
  // Your existing domain properties
  final String? searchQuery;
  final String? department;

  UserPageState({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.users,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.searchQuery,
    this.department,
  });

  @override
  List<User> get items => users;

  @override
  UserPageState copyWith({
    // Include all properties: base class + mixin + your own
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<User>? users,
    List<User>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? searchQuery,
    String? department,
  }) {
    return UserPageState(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      users: users ?? items ?? this.users,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      department: department ?? this.department,
    );
  }

  // Custom domain methods
  UserPageState withSearch(String query) {
    return copyWith(searchQuery: query, page: 0, hasMore: true);
  }
}

// Your notifier works exactly the same!
class UserNotifier extends GenericListNotifier<User, UserPageState> {
  @override
  UserPageState build() => UserPageState(
    id: 'user_list',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    users: [],
    isLoading: true,
  );

  @override
  Future<bool> refresh() async {
    state = state.copyWith(isLoading: true);
    // ... your refresh logic
    return true;
  }

  @override
  Future<bool> loadMore() async {
    // ... your load more logic
    return true;
  }
}
```

---

## Approach 2: Using ListStateMixin (Simplified)

**Best for:** Simple existing models where you want minimal boilerplate

### Example: Simple Product Model

```dart
// Your existing model (unchanged)
class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  
  Product({required this.id, required this.name, required this.price, required this.category});
}

// ✅ Simple state with default implementations
class ProductPageState with ListStateMixin<Product> {
  final List<Product> products;
  
  // ListStateMixin provides default implementations for:
  // - int get page => 0
  // - bool get hasMore => true  
  // - bool get isLoading => false
  
  // Override only if you need different defaults
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  final bool isLoading;
  
  // Your custom properties
  final String? selectedCategory;

  ProductPageState({
    required this.products,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.selectedCategory,
  });

  @override
  List<Product> get items => products;

  @override
  ProductPageState copyWith({
    List<Product>? products,
    List<Product>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? selectedCategory,
  }) {
    return ProductPageState(
      products: products ?? items ?? this.products,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
```

---

## Approach 3: Wrapper Pattern

**Best for:** Complex existing models you cannot or don't want to modify

### Example: Complex Order Model

```dart
// Your existing complex model (completely unchanged!)
class Order {
  final String id;
  final String customerId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;

  Order({...});

  // All your existing business logic remains untouched
  double calculateTax() => totalAmount * 0.1;
  bool canCancel() => status == OrderStatus.pending;
  String getDisplayStatus() => status.toString().split('.').last;
}

// ✅ Create a separate wrapper state
class OrderListState with GenericListMixin<Order> {
  final List<Order> orders;
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  final bool isLoading;
  
  // Add your list-specific filtering/sorting state
  final OrderStatus? statusFilter;
  final DateRange? dateRange;

  OrderListState({
    required this.orders,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.statusFilter,
    this.dateRange,
  });

  @override
  List<Order> get items => orders;

  @override
  OrderListState copyWith({...}) {
    return OrderListState(...);
  }
  
  // List-specific methods
  OrderListState withStatusFilter(OrderStatus status) {
    return copyWith(statusFilter: status, page: 0, hasMore: true);
  }
}

// Your Order model stays exactly the same!
// All business logic methods still work: order.calculateTax(), order.canCancel(), etc.
```

---

## Usage in UI

All approaches work identically with `GenericRefreshList`:

```dart
class MyListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GenericRefreshList<YourModel, YourState, YourNotifier>(
      provider: yourProvider,
      itemBuilder: (context, item, index) => ListTile(
        title: Text(item.name),
        // Use all existing model methods normally
        subtitle: Text(item.someExistingMethod()),
      ),
      placeholderItemBuilder: (context, index) => const ListTile(
        title: Text('Loading...'),
      ),
    );
  }
}
```

---

## Migration Strategies

### From Existing ListView to GenericRefreshList

**Before:**
```dart
class MyPage extends StatefulWidget {
  // 50+ lines of boilerplate for pagination, refresh, loading states...
}
```

**After (Choose any approach):**
```dart
// Option A: Mixin approach
class MyState with GenericListMixin<MyModel> { /* 10 lines */ }

// Option B: Wrapper approach  
class MyListState with GenericListMixin<MyModel> { /* 10 lines */ }

// Option C: Simple mixin
class MyState with ListStateMixin<MyModel> { /* 5 lines */ }

// Usage (same for all)
GenericRefreshList<MyModel, MyState, MyNotifier>(...)
```

### Choosing the Right Approach

**Use GenericListMixin when:**
- ✅ Your model already extends another class
- ✅ You need full control over list properties
- ✅ You want to add list functionality to existing state classes

**Use ListStateMixin when:**
- ✅ You have simple models
- ✅ You want minimal boilerplate
- ✅ Default property values work for you

**Use Wrapper Pattern when:**
- ✅ You cannot modify existing models
- ✅ Models have complex business logic
- ✅ You want complete separation of concerns

---

## Advanced Patterns

### Combining Multiple Models

```dart
// Wrapper that handles multiple model types
class DashboardState with GenericListMixin<DashboardItem> {
  final List<User> users;
  final List<Order> orders;
  final List<Product> products;
  
  @override
  List<DashboardItem> get items {
    // Combine different models into a unified list
    return [
      ...users.map((u) => DashboardItem.user(u)),
      ...orders.map((o) => DashboardItem.order(o)),
      ...products.map((p) => DashboardItem.product(p)),
    ];
  }
}
```

### Type-Safe Domain Methods

```dart
class UserListState with GenericListMixin<User> {
  
  // Type-safe domain methods
  UserListState withSearch(String query) {
    return copyWith(searchQuery: query, page: 0, hasMore: true);
  }
  
  UserListState withDepartment(String dept) {
    return copyWith(department: dept, page: 0, hasMore: true);
  }
  
  List<User> get activeUsers => items.where((u) => u.isActive).toList();
  List<User> get adminUsers => items.where((u) => u.isAdmin).toList();
}
```

---

## Best Practices

1. **Keep Existing Models Unchanged**: Prefer composition over modification
2. **Use Type-Safe Methods**: Create domain-specific methods that return the correct type
3. **Separate Concerns**: Keep list logic separate from business logic
4. **Test Migration**: Start with one model, then expand to others
5. **Document Approach**: Choose one pattern and document it for your team

---

## Examples in Codebase

- **Basic Mixin**: `demos/existing_model_examples.dart` - `UserPageState`
- **Simple Mixin**: `demos/existing_model_examples.dart` - `ProductPageState`  
- **Wrapper Pattern**: `demos/existing_model_examples.dart` - `OrderListState`
- **Migration Example**: `demos/generic_refresh_list_example.dart` - Shows before/after

The flexibility of mixins means you can integrate `GenericRefreshList` with any existing codebase without major refactoring!