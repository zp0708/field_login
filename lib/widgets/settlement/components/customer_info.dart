import 'package:flutter/material.dart';
import '../../../style/adapt.dart';

/// Widget that displays customer information with avatar, name, and phone
class CustomerInfo extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarUrl;
  final String? location;
  final String? badge;

  const CustomerInfo({
    super.key,
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.location,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.dp),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          SizedBox(width: 12.dp),

          // Customer details
          Expanded(
            child: _buildCustomerDetails(),
          ),

          // Location and badge
          if (location != null || badge != null) _buildLocationBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50.dp,
      height: 50.dp,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
        size: 25.dp,
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16.dp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.dp),
            Text(
              '李小美就是美的那个美',
              style: TextStyle(
                fontSize: 12.dp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4.dp),
        Row(
          children: [
            Text(
              _formatPhoneNumber(phone),
              style: TextStyle(
                fontSize: 14.dp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 8.dp),
            Icon(
              Icons.content_copy,
              size: 14.dp,
              color: Colors.grey[500],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationBadge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (location != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 12.dp,
                color: Colors.red,
              ),
              SizedBox(width: 2.dp),
              Text(
                location!,
                style: TextStyle(
                  fontSize: 12.dp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.dp),
        ],
        if (badge != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.dp, vertical: 2.dp),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8.dp),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 10.dp,
                  color: Colors.white,
                ),
                SizedBox(width: 2.dp),
                Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10.dp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length >= 7) {
      return '${phone.substring(0, 3)} **** ${phone.substring(phone.length - 4)}';
    }
    return phone;
  }
}
