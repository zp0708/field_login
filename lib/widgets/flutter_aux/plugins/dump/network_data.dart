import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:field_login/widgets/flutter_aux/plugins/dump/page/dump_list_page.dart';
import 'package:flutter/material.dart';

class NetworkData extends Pluggable {
  @override
  String get name => 'network_data';

  @override
  Widget get display => const Text('抓包');

  @override
  Size get size => const Size(600, 600);

  @override
  Offset get position => const Offset(300, 300);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<dynamic>(builder: (_) => HttpDumpListPage());
      },
    );
  }
}
