import 'package:flutter/material.dart';
import 'dump_item.dart';
import '../manager.dart';
import '../model.dart';
import 'dump_detail_page.dart';

///
class HttpDumpListPage extends StatefulWidget {
  ///
  const HttpDumpListPage({super.key});

  @override
  State<HttpDumpListPage> createState() => _HttpDumpListPageState();
}

class _HttpDumpListPageState extends State<HttpDumpListPage> {
  late List<HttpDumpRecord> _list;

  @override
  void initState() {
    _list = DumpManager.getRecordList();
    DumpManager.setObserver(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    DumpManager.setObserver(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 50),
                Text('自定义 AppBar', style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: _clear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('清空', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
          Expanded(
            child: _list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (_, int index) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      child: DumpItemWidget(
                        _list[index],
                        onTap: () => _onTapItem(index),
                      ),
                    ),
                    itemCount: _list.length,
                  ),
          ),
        ],
      ),
    );
  }

  void _onTapItem(int index) {
    Navigator.of(context).push<dynamic>(
        MaterialPageRoute<dynamic>(builder: (_) => HttpDumpDetailPage(_list[index])));
  }

  void _clear() {
    DumpManager.clear();
    setState(() {});
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.network_check,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无抓包记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始网络请求后，这里会显示抓包记录',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
