import 'package:flutter/material.dart';
import 'package:manicure/conf/env.dart';
import 'package:manicure/conf/host.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pluggable.dart';
import '../flutter_aux.dart';

class HostSettings extends Pluggable {
  @override
  String get name => 'host_settings';

  @override
  String get display => '域名设置';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return const HostSettingsPage();
  }

  static Future<void> setHost() async {
    final env = Env.mode;
    // 只在开发环境处理
    if (env != Env.dev) return;
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host_settings_current_host');
    if (host == null || host.isEmpty) return;
    Env.host = 'http://$host';
  }
}

class HostSettingsPage extends StatefulWidget {
  const HostSettingsPage({super.key});

  @override
  State<HostSettingsPage> createState() => _HostSettingsPageState();
}

class _HostSettingsPageState extends State<HostSettingsPage> {
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

  void _setHost(String? host) {
    if (host == null || host.isEmpty) {
      Env.host = Host.dev_host;
    } else {
      Env.host = 'http://$host';
    }
  }

  // 加载代理设置和历史记录
  Future<void> _loadProxySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentProxy = prefs.getString('host_settings_current_host');
      final historyJson = prefs.getStringList('host_settings_host_history') ?? [];
      setState(() {
        _proxyHistory.clear();
        _proxyHistory.addAll(historyJson);
        if (_currentProxy != null) {
          _proxyController.text = _currentProxy!;
        }
        _isLoading = false;
        _setHost(_currentProxy);
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
      _setHost(proxy);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('host_settings_current_host', proxy);

      // 添加到历史记录（如果不存在）
      if (!_proxyHistory.contains(proxy)) {
        _proxyHistory.insert(0, proxy);
        // 限制历史记录数量为20条
        if (_proxyHistory.length > 20) {
          _proxyHistory.removeLast();
        }
        await prefs.setStringList('host_settings_host_history', _proxyHistory);
      }

      setState(() {
        _currentProxy = proxy;
      });

      _showSnackBar('域名设置保存成功');
    } catch (e) {
      _showSnackBar('保存失败: $e');
    }
  }

  // 清除当前代理
  Future<void> _clearProxy() async {
    _setHost(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('host_settings_current_host');
      setState(() {
        _currentProxy = null;
        _proxyController.clear();
      });
      _showSnackBar('域名已清除');
    } catch (e) {
      _showSnackBar('清除失败: $e');
    }
  }

  // 删除历史记录
  Future<void> _deleteHistoryItem(String proxy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _proxyHistory.remove(proxy);
      await prefs.setStringList('host_settings_host_history', _proxyHistory);
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
    FlutterAux.onMessage(message);
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
            '域名设置',
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
                    hintText: '请输入域名地址 (例如: 127.0.0.1:8080)',
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
                child: const Text('清除当前域名'),
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
                          tooltip: '选择此域名',
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
