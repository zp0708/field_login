import 'dart:math';

import 'package:flutter/material.dart';

class PageViewDemo extends StatefulWidget {
  const PageViewDemo({super.key});

  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.yellow,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.arrow_left),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: PageView.builder(
                              itemCount: 100,
                              itemBuilder: (context, idx) {
                                return PageViewItem(idx);
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Icon(Icons.close),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_right),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageViewItem extends StatelessWidget {
  final int index;
  const PageViewItem(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: getRandomColor(),
      child: Text('$index'),
    );
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255, // 不透明
      random.nextInt(256), // R
      random.nextInt(256), // G
      random.nextInt(256), // B
    );
  }
}
