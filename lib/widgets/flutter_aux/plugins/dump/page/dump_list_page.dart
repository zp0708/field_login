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
  late TextEditingController _searchController;
  String _keyword = '';

  @override
  void initState() {
    _list = DumpManager.getRecordList();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _keyword = _searchController.text.trim();
      });
    });
    DumpManager.setObserver(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    DumpManager.setObserver(null);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildBar(),
          _buildSearchBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_filteredList.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
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
          _filteredList[index],
          highlight: _keyword,
          onTap: () => _onTapItem(_filteredList[index]),
        ),
      ),
      itemCount: _filteredList.length,
    );
  }

  Widget _buildBar() {
    return Container(
      height: 50,
      width: double.infinity,
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 30),
          Text('接口列表', style: TextStyle(color: Colors.white)),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(top: 5),
      alignment: Alignment.center,
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        cursorColor: Colors.blue,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: '搜索 URI 关键字',
          prefixIcon: Icon(Icons.search, size: 18, color: Colors.blue),
          suffixIcon: _keyword.isEmpty
              ? null
              : InkWell(
                  onTap: () {
                    _searchController.clear();
                  },
                  child: Icon(Icons.clear, size: 18, color: Colors.blue),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  void _onTapItem(HttpDumpRecord record) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (_) => HttpDumpDetailPage(record)));
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

  List<HttpDumpRecord> get _filteredList {
    if (_keyword.isEmpty) return _list;
    final String kw = _keyword.toLowerCase();
    return _list.where((HttpDumpRecord r) => r.uri.toLowerCase().contains(kw)).toList();
  }
}
