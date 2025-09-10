// @Author: AI Assistant
// @Date: 2025/1/27
// @Desc: Generic Refresh List Component

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Generic list model mixin - can be mixed into existing models
mixin GenericListMixin<T> {
  List<T> get items;
  bool get hasMore;
  int get page;
  bool get isLoading;

  /// Copy method that preserves the concrete type
  /// Implementers should override this to return their concrete type
  GenericListMixin<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? page,
    bool? isLoading,
  });
}

/// Generic list notifier interface - works with mixin, interface, and base class
abstract class GenericListNotifier<T, M extends GenericListMixin<T>> extends AutoDisposeNotifier<M> {
  Future<bool> refresh();
  Future<bool> loadMore();
}

/// Generic refresh list widget
class GenericRefreshList<T, M extends GenericListMixin<T>, N extends GenericListNotifier<T, M>>
    extends ConsumerStatefulWidget {
  const GenericRefreshList({
    super.key,
    required this.provider,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.enableSkeleton = true,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.onItemTap,
  });

  /// Provider for the list notifier (can be either NotifierProvider or AutoDisposeNotifierProvider)
  final dynamic provider;

  /// Builder for each list item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Builder for separators between items
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Builder for empty state
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Builder for error state
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// List padding
  final EdgeInsetsGeometry? padding;

  /// List physics
  final ScrollPhysics? physics;

  /// Whether the list should shrink wrap
  final bool shrinkWrap;

  /// Whether to enable skeleton loading
  final bool enableSkeleton;

  /// Whether to enable pull-to-refresh
  final bool enableRefresh;

  /// Whether to enable pull-up to load more
  final bool enableLoadMore;

  /// Callback when item is tapped
  final void Function(T item, int index)? onItemTap;

  @override
  ConsumerState<GenericRefreshList<T, M, N>> createState() => _GenericRefreshListState<T, M, N>();
}

class _GenericRefreshListState<T, M extends GenericListMixin<T>, N extends GenericListNotifier<T, M>>
    extends ConsumerState<GenericRefreshList<T, M, N>> {
  late EasyRefreshController refreshController;
  bool _isNeedSkeleton = true;

  @override
  void initState() {
    super.initState();
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;

    // Access notifier dynamically to work with both NotifierProvider and AutoDisposeNotifierProvider
    final notifier = ref.read(widget.provider.notifier) as N;
    final result = await notifier.refresh();
    _isNeedSkeleton = false;
    refreshController.finishRefresh(
      result ? IndicatorResult.success : IndicatorResult.fail,
    );
  }

  Future<void> _onLoad() async {
    if (!mounted) return;

    final state = ref.read(widget.provider) as M;
    if (!state.hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    final notifier = ref.read(widget.provider.notifier) as N;
    final result = await notifier.loadMore();

    refreshController.finishLoad(
      result
          ? ((ref.read(widget.provider) as M).hasMore ? IndicatorResult.success : IndicatorResult.noMore)
          : IndicatorResult.fail,
    );
  }

  Widget _buildEmptyWidget() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }

    return const Center(
      child: Text(
        '暂无数据',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildListView(M state) {
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return GestureDetector(
            onTap: widget.onItemTap != null ? () => widget.onItemTap!(item, index) : null,
            child: widget.itemBuilder(context, item, index),
          );
        },
        separatorBuilder: widget.separatorBuilder!,
      );
    } else {
      return ListView.builder(
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return GestureDetector(
            onTap: widget.onItemTap != null ? () => widget.onItemTap!(item, index) : null,
            child: widget.itemBuilder(context, item, index),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider) as M;
    final showSkeleton = widget.enableSkeleton && _isNeedSkeleton;

    return Skeletonizer(
      enabled: showSkeleton,
      textBoneBorderRadius: TextBoneBorderRadius(BorderRadius.circular(2.0)),
      child: EasyRefresh(
        header: widget.enableRefresh ? ClassicHeader(showMessage: false) : null,
        footer: widget.enableLoadMore ? ClassicFooter(showMessage: false) : null,
        controller: refreshController,
        canRefreshAfterNoMore: true,
        canLoadAfterNoMore: true,
        onRefresh: widget.enableRefresh ? _onRefresh : null,
        onLoad: widget.enableLoadMore ? _onLoad : null,
        child: state.items.isEmpty ? _buildEmptyWidget() : _buildListView(state),
      ),
    );
  }
}
