import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_aux.dart';
import 'pluggable.dart';

class SharedPreferencesPlugin extends Pluggable {
  @override
  String get name => 'shared_preferences';

  @override
  String get display => '本地存储';

  @override
  Size get size => const Size(600, 600);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateInitialRoutes: (NavigatorState state, _) => [
        MaterialPageRoute(
          builder: (_) => _SharedPreferencesInspector(),
        ),
      ],
    );
  }
}

extension BoolParsing on String {
  bool? tryParseBool() {
    if (toLowerCase() == 'true') {
      return true;
    }
    if (toLowerCase() == 'false') {
      return false;
    }
    return null;
  }
}

class _SharedPreferencesInspector extends StatefulWidget {
  const _SharedPreferencesInspector();

  @override
  State<_SharedPreferencesInspector> createState() => _SharedPreferencesInspectorState();
}

class SharePreferencesModel {
  late String key;
  Object? value;

  SharePreferencesModel({required this.key, this.value});
}

class _SharedPreferencesInspectorState extends State<_SharedPreferencesInspector> {
  List<SharePreferencesModel> sharePreferencesList = <SharePreferencesModel>[];
  List<SharePreferencesModel> _filteredList = <SharePreferencesModel>[];
  late TextEditingController _searchController;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _keyword = _searchController.text.trim();
        _filter();
      });
    });
    loadSharedPreferencesData();
  }

  void loadSharedPreferencesData() {
    SharedPreferences.getInstance().then(
      (value) => setState(() {
        final keys = value.getKeys().toList()..sort();
        sharePreferencesList = [];
        for (var key in keys) {
          sharePreferencesList.add(SharePreferencesModel(key: key, value: value.get(key)));
        }
        _filter();
      }),
    );
  }

  void _filter() {
    if (_keyword.isEmpty) {
      _filteredList = sharePreferencesList;
    }
    final String kw = _keyword.toLowerCase();
    _filteredList = sharePreferencesList.where((SharePreferencesModel r) {
      return r.key.toLowerCase().contains(kw);
    }).toList();
  }

  void _push(SharePreferencesModel model) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _SharedPreferencesDetail(model: model),
      ),
    );
    setState(() => loadSharedPreferencesData());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemBuilder: (ctx, index) {
                  final model = _filteredList[index];
                  return GestureDetector(
                    onTap: () => _push(model),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      title: Text(model.key),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
                separatorBuilder: (ctx, index) => Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 0.5,
                ),
                itemCount: _filteredList.length,
              ),
            ),
          ],
        ),
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
          hintText: '搜索 Key',
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
}

class _SharedPreferencesDetail extends StatefulWidget {
  final SharePreferencesModel model;

  const _SharedPreferencesDetail({
    required this.model,
  });

  @override
  State<_SharedPreferencesDetail> createState() => _SharedPreferencesItemCellState();
}

class _SharedPreferencesItemCellState extends State<_SharedPreferencesDetail> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    controller.text = widget.model.value.toString();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('编辑'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            onPressed: () async {
              final share = await SharedPreferences.getInstance();
              await share.remove(widget.model.key);
              if (context.mounted) {
                Navigator.of(context).pop();
                FlutterAux.showMessage(context, '删除成功');
              }
            },
            child: Text(
              '删除',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10),
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
            ),
            onPressed: () async {
              final value = await SharedPreferences.getInstance();
              if (widget.model.value.runtimeType == double) {
                if (double.tryParse(controller.text) != null) {
                  await value.setDouble(
                    widget.model.key,
                    double.tryParse(controller.text)!,
                  );
                } else {
                  debugPrint("${controller.text} can not parse to double");
                }
              } else if (widget.model.value.runtimeType == int) {
                if (int.tryParse(controller.text) != null) {
                  await value.setInt(widget.model.key, int.parse(controller.text));
                } else {
                  debugPrint("${controller.text} can not parse to int");
                }
              } else if (widget.model.value.runtimeType == bool) {
                if (controller.text.tryParseBool() != null) {
                  await value.setBool(widget.model.key, controller.text.tryParseBool()!);
                } else {
                  debugPrint("${controller.text} can not parse to bool");
                }
              } else if (widget.model.value.runtimeType == String) {
                await value.setString(widget.model.key, controller.text);
              } else if (widget.model.value.runtimeType.toString() == "List<String>") {
                var data = controller.text.replaceFirst('[', '');
                data = data.replaceFirst(']', '');
                var list = data.split(',');
                var listData = <String>[];
                for (var element in list) {
                  listData.add(element.trim());
                }
                debugPrint("list is $listData");
                await value.setStringList(widget.model.key, listData);
              }
              if (context.mounted) FlutterAux.showMessage(context, '保存成功');
            },
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key: ${widget.model.key}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 15),
              Text(
                'Runtimetype: ${widget.model.value.runtimeType}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 15),
              TextField(
                maxLines: 10,
                focusNode: _focusNode,
                controller: controller,
                decoration: InputDecoration(
                  // border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
