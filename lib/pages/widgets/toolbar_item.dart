/// 工具栏项目模型
class ToolbarItem {
  final String name;
  final String url;
  final String? id;
  bool selected;

  ToolbarItem({
    required this.name,
    required this.url,
    this.id,
    this.selected = false,
  });

  /// 从 Map 创建 ToolbarItem（向后兼容）
  factory ToolbarItem.fromMap(Map<String, dynamic> map) {
    return ToolbarItem(
      name: map['name'] as String? ?? '',
      url: map['url'] as String? ?? '',
      id: map['id'] as String?,
      selected: map['selected'] as bool? ?? false,
    );
  }

  /// 转换为 Map（向后兼容）
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'id': id,
      'selected': selected,
    };
  }

  /// 复制并修改某些属性
  ToolbarItem copyWith({
    String? name,
    String? url,
    String? id,
    bool? selected,
  }) {
    return ToolbarItem(
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
      selected: selected ?? this.selected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToolbarItem && other.name == name && other.url == url && other.id == id;
  }

  @override
  int get hashCode => Object.hash(name, url, id);

  @override
  String toString() => 'ToolbarItem(name: $name, color: $url, selected: $selected)';
}
