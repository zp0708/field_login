import 'package:field_login/widgets/clip_shadow_path.dart';
import 'package:flutter/material.dart';

class HeaderLeftClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const itemWidth = 168.0;
    const bottomHeight = 0;
    final radius = size.height * 0.5;
    var path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 20)
      ..quadraticBezierTo(0, 0, 20, 0)
      ..lineTo(itemWidth - radius * 2, 0)
      ..quadraticBezierTo(itemWidth - radius, 0, itemWidth - radius, radius)
      ..lineTo(itemWidth - radius, size.height - radius - bottomHeight)
      ..quadraticBezierTo(itemWidth - radius, size.height - bottomHeight, itemWidth, size.height - bottomHeight)
      ..lineTo(size.width, size.height - bottomHeight)
      ..lineTo(size.width, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeaderCenterClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(20, size.height, 20, size.height - 20)
      ..lineTo(20, 20)
      ..quadraticBezierTo(20, 0, 40, 0)
      ..lineTo(size.width - 40, 0)
      ..quadraticBezierTo(size.width - 20, 0, size.width - 20, 20)
      ..lineTo(size.width - 20, size.height - 20)
      ..quadraticBezierTo(size.width - 20, size.height, size.width, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeaderRightClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = size.height * 0.5;
    var path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(radius, size.height, radius, size.height - 20)
      ..lineTo(radius, radius)
      ..quadraticBezierTo(radius, 0, radius * 2, 0)
      ..lineTo(size.width - 20, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeaderContainerPath extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    return Rect.fromLTRB(-10, -10, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class ClipSegmentWidget extends StatefulWidget {
  const ClipSegmentWidget({
    super.key,
    required this.titles,
    required this.height,
    required this.width,
  });
  final List<String> titles;
  final double height;
  final double width;

  @override
  _ClipSegmentWidget createState() => _ClipSegmentWidget();
}

class _ClipSegmentWidget extends State<ClipSegmentWidget> {
  bool activeIndex = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 300, width: 300, child: _buildHeader());
  }

  _buildHeader() {
    return ClipRect(
      clipper: HeaderContainerPath(),
      child: SizedBox(
        child: Stack(
          children: activeIndex == false
              ? [
                  _buildItem(widget.titles[0], true),
                  _buildItem(widget.titles[1], false),
                ]
              : [
                  _buildItem(widget.titles[1], false),
                  _buildItem(widget.titles[0], true),
                ],
        ),
      ),
    );
  }

  _buildItem(String title, bool isLeft) {
    return Positioned(
      left: isLeft ? 0 : widget.width - widget.height,
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeIndex = isLeft;
          });
        },
        child: ClipShadowPath(
          shadow: BoxShadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 10),
          clipper: isLeft ? HeaderLeftClipPath() : HeaderRightClipPath(),
          child: Container(
            width: 168,
            height: 44,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: isLeft ? Colors.white : Color(0xFFF5FFCE)),
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 17, color: Color(0xFF1E230F)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
