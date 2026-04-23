import 'package:field_login/widgets/json_viewer/json_search_bar.dart';
import 'package:field_login/widgets/json_viewer/json_viewer.dart';
import 'package:flutter/material.dart';

class JsonViewDemo extends StatefulWidget {
  const JsonViewDemo({super.key});

  @override
  State<JsonViewDemo> createState() => _JsonViewDemoState();
}

class _JsonViewDemoState extends State<JsonViewDemo> {
  final editController = TextEditingController();
  final jsonController = JsonTreeController();

  @override
  void dispose() {
    jsonController.dispose();
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final json = _getJson();
    final map = {};
    for (var i = 0; i < 10; i++) {
      map[i.toString()] = json;
    }
    return Scaffold(
      appBar: AppBar(title: Text('JsonViewer')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JsonSearchBar(jsonController: jsonController),
            ),
            Expanded(
              child: JsonTreeView(
                json: map,
                controller: jsonController,
                showLineNumber: true,
                expandLevel: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map _getJson() {
  return {
    "status_code": 0,
    "status_msg": "成功",
    "items": List.generate(10, (i) => _item()),
    "total_cnt": 12,
    "user": {
      "id": "1000039",
      "phone_number": "18621515491",
      "name": "摩笔_unxn2Mp9",
      "appellation": "赵先生",
      "avatar":
          "https://macbrush-shop-image.oss-cn-shanghai.aliyuncs.com/manicure/1762928613115813_lrca3m.jpeg",
      "gender": 2,
      "country": "CN",
      "bg_image": "background/test1.png",
      "signature": "测试账号",
      "status": 1,
      "level": 1,
      "tags": ["下单五次", "指甲比较软", "偏爱猫眼", "频次较高"],
      "create_time": 1758005569,
      "is_edit_name": false,
      "last_login_time": 1773804051,
      "last_login_platform": "Mobi M站",
      "device_type": "未知设备",
      "summary": {},
    },
  };
}

Map _item() {
  return {
    "order_id": "2026032715552600049629",
    "item_id": "2026032715552600016225",
    "sku_id": 11077109000001,
    "category_id": 1,
    "order_status": 1,
    "quantity": 1,
    "order_amount": 0.01,
    "reduction_amount": 0,
    "discount_amount": 0,
    "pay_amount": 0.01,
    "refund_amount": 0,
    "pay_id": "",
    "create_time": 1774598127,
    "ext": {},
    "sku": {
      "sku_id": 11077109000001,
      "category_id": 1,
      "product_id": 1077,
      "status": 1,
      "price": 0.01,
      "name": "1分钱商品",
      "image":
          "https://macbrush-shop-image.oss-cn-shanghai.aliyuncs.com/product/1761196848137_vk8qmv.png" *
              10,
      "cost_time": 3600,
      "sku_params": [
        {"id": 101, "name": "金色"},
      ],
    },
    "service": {
      "service_id": "2026032715552600051687",
      "serial_number": "100701",
      "store_id": "10001",
      "order_id": "2026032715552600049629",
      "user_id": "1000039",
      "template_id": "2026020318155700062811",
      "status": 4,
      "planned_start_time": 1774603800,
      "planned_end_time": 1774840032,
      "start_time": 1774836432,
      "end_time": 1774836438,
      "process_type": 1,
      "processes": List.generate(4, (i) => _process()),
      "remarks": "",
      "ext": {"style_model": "zip/1-69c4cceb-168f1f-a3791870412b.zip"},
      "biz_type": 1,
      "create_time": 1774598127,
    },
    "latest_repair_info": {"can_repair": 0},
  };
}

Map _process() {
  return {
    "service_process_id": "2026032715552600051687_2",
    "process_template_id": "2026020318131400042571",
    "name": "2D打印",
    "icon":
        "https://macbrush-shop-image.oss-cn-shanghai.aliyuncs.com/progress/1770113586547_u6d89y.png",
    "type": 1,
    "status": 0,
    "process_start_time": 0,
    "process_end_time": 0,
    "service_process": "2026032715552600051687_2",
    "start_time": 0,
    "end_time": 0,
    "device_id": "",
    "serve_staff": "",
  };
}
