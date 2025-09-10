// @Author: AI Assistant
// @Date: 2025/1/27
// @Desc: Example usage of GenericRefreshList for different scenarios

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/generic_refresh/generic_refresh_list.dart';

/// Example 1: User List Implementation
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});
}

class UserListModel implements GenericListModel<UserModel> {
  final List<UserModel> userList;
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  final bool isLoading;

  UserListModel({
    required this.userList,
    required this.page,
    required this.hasMore,
    this.isLoading = false,
  });

  @override
  List<UserModel> get items => userList;

  @override
  UserListModel copyWith({
    List<UserModel>? userList,
    List<UserModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return UserListModel(
      userList: userList ?? items ?? this.userList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserListNotifier extends GenericListNotifier<UserModel, UserListModel> {
  @override
  UserListModel build() {
    return UserListModel(
      userList: [],
      page: 0,
      hasMore: true,
      isLoading: true,
    );
  }

  @override
  Future<bool> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final users = List.generate(
        10,
        (index) => UserModel(
          id: 'user_$index',
          name: 'User $index',
          email: 'user$index@example.com',
        ),
      );

      state = UserListModel(
        userList: users,
        page: 1,
        hasMore: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  @override
  Future<bool> loadMore() async {
    if (!state.hasMore) return false;

    try {
      // Simulate API call for next page
      await Future.delayed(const Duration(seconds: 1));
      final newUsers = List.generate(
        10,
        (index) => UserModel(
          id: 'user_${state.userList.length + index}',
          name: 'User ${state.userList.length + index}',
          email: 'user${state.userList.length + index}@example.com',
        ),
      );

      state = state.copyWith(
        userList: [...state.userList, ...newUsers],
        page: state.page + 1,
        hasMore: newUsers.length >= 10,
        isLoading: false,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

final userListProvider = NotifierProvider.autoDispose<UserListNotifier, UserListModel>(() {
  return UserListNotifier();
});

/// Example Usage in Widget
class UserListPage extends ConsumerWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户列表')),
      body: GenericRefreshList<UserModel, UserListModel, UserListNotifier>(
        provider: userListProvider,
        itemBuilder: (context, user, index) => ListTile(
          leading: CircleAvatar(child: Text(user.name[0])),
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () => debugPrint('Tapped user: ${user.name}'),
        ),
        separatorBuilder: (context, index) => const Divider(),
        emptyBuilder: (context) => const Center(
          child: Text('暂无用户数据'),
        ),
        onItemTap: (user, index) {
          debugPrint('User tapped: ${user.name}');
        },
      ),
    );
  }
}

/// Example 2: Product List (similar pattern)
class ProductModel {
  final String id;
  final String name;
  final double price;

  ProductModel({required this.id, required this.name, required this.price});
}

// ... Similar implementation for ProductListModel, ProductListNotifier, etc.

/// Example 3: News/Article List (similar pattern)
class ArticleModel {
  final String id;
  final String title;
  final String content;
  final DateTime publishDate;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.publishDate,
  });
}

// ... Similar implementation for ArticleListModel, ArticleListNotifier, etc.

/*
Usage Benefits:

1. **Consistent Pattern**: All list pages follow the same structure
2. **Reduced Boilerplate**: No need to implement refresh logic repeatedly
3. **Easy Customization**: Override emptyBuilder, errorBuilder, itemBuilder as needed
4. **Type Safety**: Full type safety with generics
5. **Flexible**: Works with any data model that implements GenericListModel
6. **Performance**: Built-in skeleton loading and optimized refresh handling

Quick Setup Steps:
1. Create your data model (e.g., UserModel)
2. Create a list model implementing GenericListModel<T>
3. Create a notifier extending GenericListNotifier<T, M>
4. Create a provider for your notifier
5. Use GenericRefreshList in your widget with your provider and itemBuilder

The generic component handles all the complex refresh/load more logic automatically!
*/
