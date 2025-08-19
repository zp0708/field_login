import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProxySettings extends Pluggable {
  @override
  String get name => 'proxy_settings';

  @override
  Widget get display => const Text('代理设置');

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return const ProxySettingsPage();
  }

  static Future<String?> getProxy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('proxy_settings_current_proxy');
  }
}

class ProxySettingsPage extends StatefulWidget {
  const ProxySettingsPage({super.key});

  @override
  State<ProxySettingsPage> createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  final TextEditingController _proxyController = TextEditingController();
  final List<String> _proxyHistory = [];
  String? _currentProxy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProxySettings();
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  // 加载代理设置和历史记录
  Future<void> _loadProxySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentProxy = prefs.getString('proxy_settings_current_proxy');
      final historyJson = prefs.getStringList('proxy_settings_proxy_history') ?? [];
      setState(() {
        _proxyHistory.clear();
        _proxyHistory.addAll(historyJson);
        if (_currentProxy != null) {
          _proxyController.text = _currentProxy!;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 保存代理设置
  Future<void> _saveProxy() async {
    final proxy = _proxyController.text.trim();
    if (proxy.isEmpty) {
      _showSnackBar('请输入代理地址');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('proxy_settings_current_proxy', proxy);

      // 添加到历史记录（如果不存在）
      if (!_proxyHistory.contains(proxy)) {
        _proxyHistory.insert(0, proxy);
        // 限制历史记录数量为20条
        if (_proxyHistory.length > 20) {
          _proxyHistory.removeLast();
        }
        await prefs.setStringList('proxy_settings_proxy_history', _proxyHistory);
      }

      setState(() {
        _currentProxy = proxy;
      });

      _showSnackBar('代理设置保存成功');
    } catch (e) {
      _showSnackBar('保存失败: $e');
    }
  }

  // 清除当前代理
  Future<void> _clearProxy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('proxy_settings_current_proxy');
      setState(() {
        _currentProxy = null;
        _proxyController.clear();
      });
      _showSnackBar('代理已清除');
    } catch (e) {
      _showSnackBar('清除失败: $e');
    }
  }

  // 删除历史记录
  Future<void> _deleteHistoryItem(String proxy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _proxyHistory.remove(proxy);
      await prefs.setStringList('proxy_settings_proxy_history', _proxyHistory);
      setState(() {});
      _showSnackBar('历史记录已删除');
    } catch (e) {
      _showSnackBar('删除失败: $e');
    }
  }

  // 选择历史记录
  void _selectHistoryItem(String proxy) {
    setState(() {
      _proxyController.text = proxy;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Text(
            '代理设置',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 代理输入框和按钮行
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _proxyController,
                  decoration: const InputDecoration(
                    hintText: '请输入代理地址 (例如: 127.0.0.1:8080)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saveProxy,
                child: const Text('保存'),
              ),
            ],
          ),

          // 清除代理按钮
          if (_currentProxy != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearProxy,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('清除当前代理'),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 历史记录标题
          const Text(
            '历史记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // 历史记录列表
          Expanded(
            child: _proxyHistory.isEmpty
                ? const Center(
                    child: Text(
                      '暂无历史记录',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _proxyHistory.length,
                    itemBuilder: (context, index) {
                      final proxy = _proxyHistory[index];
                      final isCurrent = proxy == _currentProxy;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            proxy,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? Colors.blue : null,
                            ),
                          ),
                          subtitle: isCurrent ? const Text('当前使用中', style: TextStyle(color: Colors.blue)) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _selectHistoryItem(proxy),
                                tooltip: '选择此代理',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteHistoryItem(proxy),
                                tooltip: '删除此记录',
                              ),
                            ],
                          ),
                          onTap: () => _selectHistoryItem(proxy),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
