import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:flutter/material.dart';

class ProxySettings extends Pluggable {
  @override
  String get name => 'proxy_settings';

  @override
  Widget get display => const Text('代理设置');

  @override
  Size get size => const Size(300, 300);

  @override
  Offset get position => const Offset(300, 300);

  @override
  Widget build(BuildContext context) {
    return Center(child: const Text('Proxy Settings'));
  }
}
