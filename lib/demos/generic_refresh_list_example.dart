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

class UserListModel with GenericListMixin<UserModel> {
  final List<UserModel> users;
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
  List<UserModel> get items => users;

  @override
  UserListModel copyWith({
    List<UserModel>? users,
    List<UserModel>? items,
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

class UserListNotifier extends GenericListNotifier<UserModel, UserListModel> {
  @override
  UserListModel build() {
    final users = List.generate(
      3,
      (index) => UserModel(
        id: 'user_$index',
        name: 'User $index',
        email: 'user$index@example.com',
      ),
    );
    return UserListModel(
      users: users,
      isLoading: true,
    );
  }

  @override
  Future<bool> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 5));
      final users = List.generate(
        10,
        (index) => UserModel(
          id: 'user_$index',
          name: 'User $index',
          email: 'user$index@example.com',
        ),
      );

      state = state.copyWith(
        users: users,
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
          id: 'user_${state.users.length + index}',
          name: 'User ${state.users.length + index}',
          email: 'user${state.users.length + index}@example.com',
        ),
      );

      state = state.copyWith(
        users: [...state.users, ...newUsers],
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
