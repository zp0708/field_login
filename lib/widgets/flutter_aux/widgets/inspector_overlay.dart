import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../utils/constants.dart';

class InspectorOverlay extends LeafRenderObjectWidget {
  const InspectorOverlay({
    super.key,
    required this.selection,
    this.needEdges = true,
    this.needDescription = true,
  });

  final InspectorSelection selection;

  final bool needDescription;

  final bool needEdges;

  @override
  RenderInspectorOverlay createRenderObject(BuildContext context) {
    return RenderInspectorOverlay(
      selection: selection,
      needDescription: needDescription,
      needEdges: needEdges,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderInspectorOverlay renderObject) {
    renderObject.selection = selection;
  }
}

class RenderInspectorOverlay extends RenderBox {
  RenderInspectorOverlay({
    required InspectorSelection selection,
    required this.needDescription,
    required this.needEdges,
  }) : _selection = selection;

  final bool needDescription;
  final bool needEdges;

  InspectorSelection get selection => _selection;
  InspectorSelection _selection;
  set selection(InspectorSelection value) {
    if (value != _selection) {
      _selection = value;
    }
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void performResize() {
    size = constraints.constrain(const Size(double.infinity, double.infinity));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(needsCompositing);
    context.addLayer(_InspectorOverlayLayer(
      needEdges: needEdges,
      needDescription: needDescription,
      overlayRect: Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      selection: selection,
    ));
  }
}

class _InspectorOverlayLayer extends Layer {
  _InspectorOverlayLayer({
    required this.overlayRect,
    required this.selection,
    required this.needDescription,
    required this.needEdges,
  });

  InspectorSelection selection;

  final bool needDescription;

  final bool needEdges;

  final Rect overlayRect;

  _InspectorOverlayRenderState? _lastState;

  late ui.Picture _picture;

  TextPainter? _textPainter;
  double? _textPainterMaxWidth;

  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    if (!selection.active) return;

    final _SelectionInfo info = _SelectionInfo(selection);
    final RenderObject? selected = info.renderObject;
    final List<_TransformedRect> candidates = <_TransformedRect>[];
    for (RenderObject candidate in selection.candidates) {
      if (candidate == selected || !candidate.attached) continue;
      candidates.add(_TransformedRect(candidate));
    }

    final _InspectorOverlayRenderState state = _InspectorOverlayRenderState(
      selectionInfo: info,
      overlayRect: overlayRect,
      selected: _TransformedRect(selected!),
      textDirection: TextDirection.ltr,
      candidates: candidates,
    );

    if (state != _lastState) {
      _lastState = state;
      _picture = _buildPicture(state);
    }
    builder.addPicture(layerOffset, _picture);
  }

  ui.Picture _buildPicture(_InspectorOverlayRenderState state) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, state.overlayRect);
    final Size size = state.overlayRect.size;

    // Enhanced fill paint with gradient
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = kHighlightedRenderObjectFillColor;

    // Enhanced border paint with glow effect
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = kHighlightedRenderObjectBorderColor;

    // Glow effect paint
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = kHighlightedRenderObjectBorderColor.withAlpha(75)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    final Rect selectedPaintRect = state.selected.rect.deflate(0.5);

    // Draw glow effect
    canvas
      ..save()
      ..transform(state.selected.transform.storage)
      ..drawRect(selectedPaintRect.inflate(2), glowPaint)
      ..restore();

    // Draw selection
    canvas
      ..save()
      ..transform(state.selected.transform.storage)
      ..drawRect(selectedPaintRect, fillPaint)
      ..drawRect(selectedPaintRect, borderPaint)
      ..restore();

    // Draw corner indicators
    final Paint cornerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = kHighlightedRenderObjectBorderColor;

    canvas
      ..save()
      ..transform(state.selected.transform.storage);

    const double cornerSize = 8.0;
    final List<Offset> corners = [
      selectedPaintRect.topLeft,
      selectedPaintRect.topRight,
      selectedPaintRect.bottomLeft,
      selectedPaintRect.bottomRight,
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, cornerSize / 2, cornerPaint);
      canvas.drawCircle(
          corner,
          cornerSize / 2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = Colors.white);
    }

    canvas.restore();

    if (needEdges) {
      final Paint candidatePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = kHighlightedRenderObjectBorderColor.withAlpha(150);

      for (_TransformedRect transformedRect in state.candidates) {
        canvas
          ..save()
          ..transform(transformedRect.transform.storage)
          ..drawRect(transformedRect.rect.deflate(0.5), candidatePaint)
          ..restore();
      }
    }

    final Rect targetRect = MatrixUtils.transformRect(state.selected.transform, state.selected.rect);
    final Offset target = Offset(targetRect.left, targetRect.center.dy);
    const double offsetFromWidget = 12.0;
    final double verticalOffset = (targetRect.height) / 2 + offsetFromWidget;

    if (needDescription) {
      _paintDescription(
          canvas, state.selectionInfo.message, state.textDirection, target, verticalOffset, size, targetRect);
    }
    return recorder.endRecording();
  }

  void _paintDescription(
    Canvas canvas,
    String message,
    TextDirection textDirection,
    Offset target,
    double verticalOffset,
    Size size,
    Rect targetRect,
  ) {
    canvas.save();
    final double maxWidth = size.width - 2 * (kScreenEdgeMargin + kTooltipPadding);
    final TextSpan? textSpan = _textPainter?.text as TextSpan?;
    if (_textPainter == null || textSpan!.text != message || _textPainterMaxWidth != maxWidth) {
      _textPainterMaxWidth = maxWidth;
      _textPainter = TextPainter()
        ..maxLines = kMaxTooltipLines
        ..ellipsis = '...'
        ..text = TextSpan(
          style: TextStyle(
            color: kTipTextColor,
            fontSize: 13.0,
            height: 1.4,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
          text: message,
        )
        ..textDirection = textDirection
        ..layout(maxWidth: maxWidth);
    }

    final Size tooltipSize = _textPainter!.size + const Offset(kTooltipPadding * 3, kTooltipPadding * 3);
    final Offset tipOffset = positionDependentBox(
      size: size,
      childSize: tooltipSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: false,
    );

    // Draw shadow
    final Paint shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withAlpha(50)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    final RRect shadowRRect = RRect.fromRectAndRadius(
      Rect.fromPoints(
        tipOffset.translate(2, 4),
        tipOffset.translate(tooltipSize.width + 2, tooltipSize.height + 4),
      ),
      Radius.circular(12),
    );
    canvas.drawRRect(shadowRRect, shadowPaint);

    // Draw tooltip background with gradient
    final Paint tooltipBackground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          kTooltipBackgroundColor,
          kTooltipBackgroundColor.withAlpha(225),
        ],
      ).createShader(Rect.fromPoints(
        tipOffset,
        tipOffset.translate(tooltipSize.width, tooltipSize.height),
      ));

    final RRect backgroundRRect = RRect.fromRectAndRadius(
      Rect.fromPoints(
        tipOffset,
        tipOffset.translate(tooltipSize.width, tooltipSize.height),
      ),
      Radius.circular(12),
    );
    canvas.drawRRect(backgroundRRect, tooltipBackground);

    // Draw border
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF3498DB).withAlpha(150)
      ..strokeWidth = 1;
    canvas.drawRRect(backgroundRRect, borderPaint);

    double wedgeY = tipOffset.dy;
    final bool tooltipBelow = tipOffset.dy > target.dy;
    if (!tooltipBelow) wedgeY += tooltipSize.height;

    const double wedgeSize = 10;
    double wedgeX = math.max(tipOffset.dx, target.dx) + targetRect.width * 0.5;
    wedgeX = math.min(wedgeX, tipOffset.dx + tooltipSize.width - wedgeSize * 2);
    final List<Offset> wedge = <Offset>[
      Offset(wedgeX - wedgeSize, wedgeY),
      Offset(wedgeX + wedgeSize, wedgeY),
      Offset(wedgeX, wedgeY + (tooltipBelow ? -wedgeSize : wedgeSize)),
    ];

    // Draw wedge shadow
    final List<Offset> shadowWedge = wedge.map((offset) => offset.translate(1, 2)).toList();
    canvas.drawPath(Path()..addPolygon(shadowWedge, true), shadowPaint);

    // Draw wedge
    final Paint wedgePaint = Paint()..color = kTooltipBackgroundColor;
    canvas.drawPath(Path()..addPolygon(wedge, true), wedgePaint);

    _textPainter!.paint(canvas, tipOffset + const Offset(kTooltipPadding * 1.5, kTooltipPadding * 1.5));
    canvas.restore();
  }

  @override
  @protected
  bool findAnnotations<S extends Object>(AnnotationResult<S> result, Offset localPosition, {required bool onlyFirst}) {
    return false;
  }
}

class _SelectionInfo {
  const _SelectionInfo(this.selection);
  final InspectorSelection selection;

  RenderObject? get renderObject => selection.current;

  Element? get element => selection.currentElement;

  Map? get jsonInfo {
    if (renderObject == null) return null;
    final widgetId = WidgetInspectorService.instance
        // ignore: invalid_use_of_protected_member
        .toId(renderObject!.toDiagnosticsNode(), '');
    if (widgetId == null) return null;
    String infoStr = WidgetInspectorService.instance.getSelectedSummaryWidget(widgetId, '');
    return json.decode(infoStr);
  }

  String? get filePath {
    final f =
        (jsonInfo != null && jsonInfo!.containsKey('creationLocation')) ? jsonInfo!['creationLocation']['file'] : '';
    return f;
  }

  int? get line {
    final l =
        (jsonInfo != null && jsonInfo!.containsKey('creationLocation')) ? jsonInfo!['creationLocation']['line'] : 0;
    return l;
  }

  String get message {
    final widgetName = element?.toStringShort() ?? 'Unknown Widget';
    final size = renderObject?.paintBounds.size ?? Size.zero;
    final fileName = filePath?.split('/').last ?? 'unknown';

    return '''📱 Widget: $widgetName
📏 Size: ${size.width.toStringAsFixed(1)} × ${size.height.toStringAsFixed(1)}
📁 File: $fileName
📍 Line: ${line ?? 'unknown'}''';
  }
}

class _InspectorOverlayRenderState {
  _InspectorOverlayRenderState({
    required this.overlayRect,
    required this.selected,
    required this.candidates,
    required this.textDirection,
    required this.selectionInfo,
  });

  final Rect overlayRect;
  final _TransformedRect selected;
  final List<_TransformedRect> candidates;
  final TextDirection textDirection;
  final _SelectionInfo selectionInfo;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;

    final _InspectorOverlayRenderState typedOther = other as _InspectorOverlayRenderState;
    return overlayRect == typedOther.overlayRect &&
        selected == typedOther.selected &&
        listEquals<_TransformedRect>(candidates, typedOther.candidates);
  }

  @override
  int get hashCode => Object.hash(overlayRect, selected, Object.hashAll(candidates));
}

class _TransformedRect {
  _TransformedRect(RenderObject object)
      : rect = object.semanticBounds,
        transform = object.getTransformTo(null);

  final Rect rect;
  final Matrix4 transform;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final _TransformedRect typedOther = other as _TransformedRect;
    return rect == typedOther.rect && transform == typedOther.transform;
  }

  @override
  int get hashCode => Object.hash(rect, transform);
}
