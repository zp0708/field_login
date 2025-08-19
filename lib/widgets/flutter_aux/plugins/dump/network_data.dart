import 'package:flutter/material.dart';
import '../../pluggable.dart';
import 'page/dump_list_page.dart';

class NetworkData extends Pluggable {
  @override
  String get name => 'network_data';

  @override
  Widget get display => const Text('抓包');

  @override
  Size get size => const Size(600, 600);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<dynamic>(builder: (_) => HttpDumpListPage());
      },
    );
  }
}
