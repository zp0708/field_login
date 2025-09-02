import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settlement/settlement.dart';
import '../style/adapt.dart';

class SettlementDemo extends StatelessWidget {
  const SettlementDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('结算单演示'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Settlement 结算单组件',
              style: TextStyle(
                fontSize: 24.dp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.dp),
            Text(
              '功能特性：',
              style: TextStyle(
                fontSize: 18.dp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.dp),
            _buildFeatureItem('✓ 使用 Riverpod 进行状态管理'),
            _buildFeatureItem('✓ 现代化服务卡片设计'),
            _buildFeatureItem('✓ 客户信息展示和头像'),
            _buildFeatureItem('✓ 服务状态和时间显示'),
            _buildFeatureItem('✓ 多种支付方式选择'),
            _buildFeatureItem('✓ 价格折扣和优惠显示'),
            _buildFeatureItem('✓ 商品标签和分类'),
            _buildFeatureItem('✓ 智能总价计算和折扣'),
            SizedBox(height: 30.dp),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProviderScope(
                      child: SettlementPage(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.dp),
                ),
              ),
              child: Text(
                '打开美甲结算页面',
                style: TextStyle(
                  fontSize: 16.dp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20.dp),
            Container(
              padding: EdgeInsets.all(16.dp),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.dp),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '使用说明：',
                    style: TextStyle(
                      fontSize: 14.dp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.dp),
                  Text(
                    '1. 点击商品前的复选框选择商品\n'
                    '2. 使用"全选"功能快速选择所有商品\n'
                    '3. 只有选择商品后"前往支付"按钮才会激活\n'
                    '4. 点击右上角按钮可切换状态\n'
                    '5. 支付处理有随机成功/失败模拟',
                    style: TextStyle(
                      fontSize: 12.dp,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.dp),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.dp,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
