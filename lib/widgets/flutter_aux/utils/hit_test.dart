import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../flutter_aux.dart';

class HitTest {
  // all of RenderObjects of current point
  static List<RenderObject> hitTest(
    Offset? position, {
    double edgeHitMargin = 0.0,
  }) {
    final dynamic ignorePointer = auxRepaintKey.currentContext?.findRenderObject();
    final RenderObject userRender = ignorePointer.child;

    bool isFullscreen(RenderObject object) {
      if (object is RenderBox) {
        final size = object.size;
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        final screen = view.physicalSize / view.devicePixelRatio;

        return size.width >= screen.width && size.height >= screen.height;
      }
      return false;
    }

    bool hitTestHelper(
      List<RenderObject> hits,
      List<RenderObject> edgeHits,
      Offset? position,
      RenderObject object,
      Matrix4 transform,
    ) {
      bool hit = false;
      final Matrix4? inverse = Matrix4.tryInvert(transform);
      if (inverse == null) {
        return false;
      }
      final Offset localPosition = MatrixUtils.transformPoint(inverse, position!);

      final List<DiagnosticsNode> children = object.debugDescribeChildren();
      for (int i = children.length - 1; i >= 0; i -= 1) {
        final DiagnosticsNode diagnostics = children[i];
        if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
            diagnostics.value is! RenderObject) {
          continue;
        }
        final RenderObject child = diagnostics.value as RenderObject;
        final Rect? paintClip = object.describeApproximatePaintClip(child);
        if (paintClip != null && !paintClip.contains(localPosition)) continue;

        final Matrix4 childTransform = transform.clone();
        object.applyPaintTransform(child, childTransform);
        if (hitTestHelper(hits, edgeHits, position, child, childTransform)) {
          hit = true;
          // 如果这个 child 是全屏层（Modal）
          if (isFullscreen(child)) {
            return true; // 直接停止，下面页面不再检测
          }
        }
      }

      final Rect bounds = object.semanticBounds;
      if (bounds.contains(localPosition)) {
        hit = true;
        if (!bounds.deflate(edgeHitMargin).contains(localPosition)) edgeHits.add(object);
      }
      if (hit) hits.add(object);
      return hit;
    }

    final List<RenderObject> regularHits = <RenderObject>[];
    final List<RenderObject> edgeHits = <RenderObject>[];

    hitTestHelper(regularHits, edgeHits, position, userRender, userRender.getTransformTo(null));
    double area(RenderObject object) {
      final Size size = object.semanticBounds.size;
      return size.width * size.height;
    }

    regularHits.sort((RenderObject a, RenderObject b) => area(a).compareTo(area(b)));
    final Set<RenderObject> hits = <RenderObject>{};
    hits.addAll(edgeHits);
    hits.addAll(regularHits);
    return hits.toList();
  }
}
