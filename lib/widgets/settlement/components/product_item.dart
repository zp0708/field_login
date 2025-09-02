import 'package:flutter/material.dart';
import '../../../style/adapt.dart';
import '../models/product.dart';

/// Widget that displays a single product item with selection checkbox
class ProductItem extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback? onTap;
  final bool showServiceInfo;

  const ProductItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onToggleSelection,
    this.onTap,
    this.showServiceInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.dp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap ?? onToggleSelection,
        child: Padding(
          padding: EdgeInsets.all(16.dp),
          child: Column(
            children: [
              // Service header with checkbox and status
              _buildServiceHeader(),
              SizedBox(height: 12.dp),

              // Main content row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  _buildProductImage(),
                  SizedBox(width: 12.dp),

                  // Product details
                  Expanded(
                    child: _buildProductDetails(),
                  ),
                ],
              ),

              // Service completion info
              if (showServiceInfo && product.serviceStatus != null) ...[
                SizedBox(height: 12.dp),
                _buildServiceInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Row(
      children: [
        // Service date/time
        if (product.serviceTime != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 4.dp),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4.dp),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatServiceTime(product.serviceTime!),
                  style: TextStyle(
                    fontSize: 12.dp,
                    color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // Selection checkbox
        GestureDetector(
          onTap: onToggleSelection,
          child: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? Colors.green : Colors.grey,
            size: 20.dp,
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80.dp,
      height: 80.dp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.dp),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.dp),
        child: Image.network(
          product.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.image,
                color: Colors.grey[400],
                size: 30.dp,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: SizedBox(
                  width: 20.dp,
                  height: 20.dp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey[400],
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontSize: 16.dp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.dp),
        Text(
          product.description,
          style: TextStyle(
            fontSize: 12.dp,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.dp),
        // Price row with discount
        _buildPriceRow(),

        // Tags if available
        if (product.tags != null && product.tags!.isNotEmpty) ...[
          SizedBox(height: 8.dp),
          _buildTags(),
        ],
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '¥${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.dp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                if (product.hasDiscount) ...[
                  SizedBox(width: 8.dp),
                  Text(
                    '¥${product.originalPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12.dp,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 2.dp),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.dp),
          ),
          child: Text(
            'x${product.quantity}',
            style: TextStyle(
              fontSize: 12.dp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 4.dp,
      children: product.tags!
          .map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 6.dp, vertical: 2.dp),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.dp),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10.dp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: EdgeInsets.all(8.dp),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6.dp),
      ),
      child: Row(
        children: [
          Icon(
            product.serviceStatus!.icon,
            size: 16.dp,
            color: product.serviceStatus!.color,
          ),
          SizedBox(width: 6.dp),
          Text(
            product.serviceStatus!.displayName,
            style: TextStyle(
              fontSize: 12.dp,
              color: product.serviceStatus!.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (product.statusText != null) ...[
            SizedBox(width: 8.dp),
            Text(
              product.statusText!,
              style: TextStyle(
                fontSize: 11.dp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatServiceTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
