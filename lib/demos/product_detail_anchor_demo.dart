import 'package:flutter/material.dart';
import '../widgets/product_detail_anchor/product_detail_anchor.dart';

class ProductDetailAnchorDemo extends StatefulWidget {
  const ProductDetailAnchorDemo({super.key});

  @override
  State<ProductDetailAnchorDemo> createState() => _ProductDetailAnchorDemoState();
}

class _ProductDetailAnchorDemoState extends State<ProductDetailAnchorDemo> {
  late List<AnchorConfig> _anchors;

  @override
  void initState() {
    super.initState();
    _initializeAnchors();
  }

  void _initializeAnchors() {
    _anchors = [
      AnchorConfig(
        id: 'overview',
        title: '商品概览',
        key: GlobalKey(),
      ),
      AnchorConfig(
        id: 'details',
        title: '商品详情',
        key: GlobalKey(),
      ),
      AnchorConfig(
        id: 'specifications',
        title: '规格参数',
        key: GlobalKey(),
      ),
      AnchorConfig(
        id: 'reviews',
        title: '用户评价',
        key: GlobalKey(),
      ),
      AnchorConfig(
        id: 'service',
        title: '售后服务',
        key: GlobalKey(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情锚点定位'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ProductDetailAnchorPage(
        anchors: _anchors,
        contentBuilder: _buildSectionContent,
        tabBarHeight: 60.0,
        stickyOffset: 100.0,
        activeTabColor: Theme.of(context).primaryColor.withOpacity(0.1),
        inactiveTabColor: Colors.transparent,
      ),
    );
  }

  /// 构建各个锚点区域的内容
  Widget _buildSectionContent(BuildContext context, AnchorConfig anchor) {
    switch (anchor.id) {
      case 'overview':
        return _buildOverviewSection();
      case 'details':
        return _buildDetailsSection();
      case 'specifications':
        return _buildSpecificationsSection();
      case 'reviews':
        return _buildReviewsSection();
      case 'service':
        return _buildServiceSection();
      default:
        return _buildDefaultSection(anchor);
    }
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('商品概览', Icons.shopping_bag),
        const SizedBox(height: 16),
        // 商品图片
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.image,
            size: 80,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        // 商品标题
        const Text(
          'iPhone 15 Pro Max 256GB 深空黑色',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // 价格
        Row(
          children: [
            const Text(
              '¥9,999',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '¥10,999',
              style: TextStyle(
                fontSize: 16,
                decoration: TextDecoration.lineThrough,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 商品特点
        _buildFeatureChips(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('商品详情', Icons.description),
        const SizedBox(height: 16),
        _buildDetailItem('品牌', 'Apple'),
        _buildDetailItem('型号', 'iPhone 15 Pro Max'),
        _buildDetailItem('颜色', '深空黑色'),
        _buildDetailItem('存储容量', '256GB'),
        _buildDetailItem('屏幕尺寸', '6.7英寸'),
        _buildDetailItem('处理器', 'A17 Pro 芯片'),
        const SizedBox(height: 16),
        const Text(
          '产品介绍',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'iPhone 15 Pro Max 配备了强大的 A17 Pro 芯片，带来卓越的性能表现。6.7 英寸 Super Retina XDR 显示屏提供绚丽的视觉体验，而钛金属设计则兼具轻盈与坚固。',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSpecificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('规格参数', Icons.settings),
        const SizedBox(height: 16),
        _buildSpecTable(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('用户评价', Icons.star),
        const SizedBox(height: 16),
        _buildReviewSummary(),
        const SizedBox(height: 16),
        ..._buildReviewList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('售后服务', Icons.support_agent),
        const SizedBox(height: 16),
        _buildServiceItem('全国联保', '享受全国范围内的保修服务'),
        _buildServiceItem('30天无理由退货', '自收货之日起30天内可无理由退货'),
        _buildServiceItem('正品保障', '100%正品，假一赔三'),
        _buildServiceItem('免费配送', '全场免费配送，次日达'),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDefaultSection(AnchorConfig anchor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(anchor.title, Icons.info),
        const SizedBox(height: 16),
        const Text('这里是默认内容区域'),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChips() {
    final features = ['全新未拆封', '顺丰包邮', '7天无理由退货', '全国联保'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) {
        return Chip(
          label: Text(
            feature,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTable() {
    final specs = [
      ['屏幕尺寸', '6.7英寸'],
      ['分辨率', '2796 x 1290 像素'],
      ['处理器', 'A17 Pro 仿生芯片'],
      ['存储', '256GB'],
      ['内存', '8GB'],
      ['摄像头', '4800万像素主摄'],
      ['电池', '4441mAh'],
      ['操作系统', 'iOS 17'],
    ];

    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FixedColumnWidth(100),
        1: FlexColumnWidth(),
      },
      children: specs.map((spec) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                spec[0],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(spec[1]),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildReviewSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '4.8',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '基于1,234条评价',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReviewList() {
    final reviews = [
      {
        'user': '张三',
        'rating': 5,
        'content': '手机很不错，运行流畅，拍照效果很好，推荐购买！',
        'date': '2024-01-15',
      },
      {
        'user': '李四',
        'rating': 4,
        'content': '整体满意，就是价格有点贵，不过一分钱一分货。',
        'date': '2024-01-10',
      },
      {
        'user': '王五',
        'rating': 5,
        'content': '苹果的品质还是很赞的，用了一段时间没有任何问题。',
        'date': '2024-01-08',
      },
    ];

    return reviews.map((review) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  review['user'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (review['rating'] as int) ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.orange,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review['content'] as String),
            const SizedBox(height: 4),
            Text(
              review['date'] as String,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildServiceItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
