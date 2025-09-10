# Generic Refresh List Component

A powerful and flexible Flutter component for implementing paginated lists with pull-to-refresh and skeleton loading functionality.

## Features

- ✅ **Skeleton Screen Loading**: Beautiful loading placeholders during data fetch
- ✅ **Pull-to-Refresh**: Standard pull-down to refresh functionality  
- ✅ **Load More**: Automatic pagination with pull-up to load more
- ✅ **Error Handling**: Built-in error state management
- ✅ **Empty State**: Customizable empty state display
- ✅ **Type Safety**: Full type safety with Dart generics
- ✅ **Flexible Architecture**: Support for mixin and inheritance patterns

## Quick Start

### Using Pure Mixin Approach (Recommended)

The cleanest way to get started is by using the mixin approach. This eliminates the need to manually implement common list properties and provides maximum flexibility.

```dart
// 1. Define your data model
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// 2. Create a simple list model using mixin
class UserListModel with GenericListMixin<User> {
  final List<User> users;
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  final bool isLoading;

  const UserListModel({
    required this.users,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
  });

  @override
  List<User> get items => users;

  @override
  UserListModel copyWith({
    List<User>? users,
    List<User>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return UserListModel(
      users: users ?? items ?? this.users,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 3. Create your notifier
class UserNotifier extends GenericListNotifier<User, UserListModel> {
  @override
  UserListModel build() => const UserListModel(users: [], isLoading: true);

  @override
  Future<bool> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final users = await fetchUsers(); // Your API call
      state = state.copyWith(users: users, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  @override
  Future<bool> loadMore() async {
    // Implementation for pagination
    return true;
  }
}

// 4. Use in your widget
class UserListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GenericRefreshList<User, UserListModel, UserNotifier>(
        provider: userProvider,
        itemBuilder: (context, user, index) => ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        ),
        placeholderItemBuilder: (context, index) => const ListTile(
          title: Text('Loading...'),
          subtitle: Text('Loading...'),
        ),
      ),
    );
  }
}
```

## Benefits Comparison

### Before (Manual Implementation)
```dart
class UserListModel implements GenericListModel<User> {
  final List<User> userList;
  final int page;           // ❌ Repetitive
  final bool hasMore;       // ❌ Repetitive  
  final bool isLoading;     // ❌ Repetitive

  UserListModel({...});     // ❌ Boilerplate constructor

  @override
  List<User> get items => userList;

  @override
  UserListModel copyWith({...}) {  // ❌ 15+ lines of boilerplate
    return UserListModel(
      userList: userList ?? items ?? this.userList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

### After (Using Mixin)
```dart
class UserListModel with GenericListMixin<User> {
  final List<User> users;
  @override final int page;
  @override final bool hasMore;
  @override final bool isLoading;

  const UserListModel({     // ✅ Simple constructor
    required this.users,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
  });

  @override
  List<User> get items => users;

  @override
  UserListModel copyWith({...}) {  // ✅ Clean implementation
    return UserListModel(...);
  }
}
```

## Advanced Features

### Custom Domain Properties

Add your own properties alongside the base list functionality:

```dart
class UserListModel with GenericListMixin<User> {
  final List<User> users;
  @override final int page;
  @override final bool hasMore;
  @override final bool isLoading;
  
  final String? searchQuery;      // ✅ Your custom properties
  final UserFilter filter;
  
  const UserListModel({
    required this.users,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.searchQuery,
    this.filter = UserFilter.all,
  });

  @override
  List<User> get items => users;

  @override
  UserListModel copyWith({...}) {
    return UserListModel(...);
  }

  // Custom domain methods
  UserListModel withSearch(String query) {
    return copyWith(searchQuery: query, page: 0, hasMore: true);
  }
}
```

### Built-in Convenience Methods

The mixin approach provides clean, simple methods:

```dart
// In your notifier
state = state.copyWith(isLoading: true);       // Set loading state
state = state.copyWith(users: newUsers);       // Replace all items
state = state.copyWith(users: [...state.users, ...moreUsers]); // Add more items
state = state.copyWith(page: state.page + 1);  // Increment page
```

### Skeleton Loading Customization

```dart
GenericRefreshList(
  // ... other properties
  placeholderItemBuilder: (context, index) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text('')),
      title: Text('Loading title...'),
      subtitle: Text('Loading description...'),
    ),
  ),
  skeletonItemCount: 8,  // Number of skeleton items
)
```

## Migration Guide

### From Manual Implementation

1. Replace `implements GenericListModel<T>` with `with GenericListMixin<T>`
2. Add required property declarations (`page`, `hasMore`, `isLoading`)
3. Implement `items` getter and `copyWith` method
4. Use direct `copyWith` calls in your notifier instead of convenience methods
5. Update constructor to use named parameters

### Example Migration

**Before:**
```dart
class ProductListModel implements GenericListModel<Product> {
  final List<Product> products;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? category;

  // 20+ lines of boilerplate...
}
```

**After:**
```dart
class ProductListModel with GenericListMixin<Product> {
  final List<Product> products;
  @override final int page;
  @override final bool hasMore;
  @override final bool isLoading;
  final String? category;  // Only your custom properties!

  const ProductListModel({...});
  
  @override
  List<Product> get items => products;
  
  @override
  ProductListModel copyWith({...}) => ProductListModel(...);
}
```

## Best Practices

1. **Use Pure Mixin** for maximum flexibility and clean architecture
2. **Implement domain-specific methods** for better API (like `withSearch`, `withFilter`)
3. **Provide custom placeholder builders** for better skeleton loading experience
4. **Handle errors gracefully** in your refresh/loadMore methods
5. **Use explicit copyWith calls** for clear and maintainable state updates

## Examples

- **Pure Mixin**: `mixin_only_example.dart` - Shows pure mixin approach
- **Basic Example**: `generic_refresh_list_example.dart` - Updated to use mixin
- **Simplified Example**: `simplified_refresh_example.dart` - Clean mixin implementation
- **Skeleton Demo**: `skeleton_demo.dart`
- **Existing Models**: `existing_model_examples.dart` - Integration with existing code

The Generic Refresh List component with pure mixin approach provides maximum flexibility while eliminating repetitive code!