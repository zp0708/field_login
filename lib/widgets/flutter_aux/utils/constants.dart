import 'package:flutter/material.dart';

import 'binding_ambiguate.dart';

const Size dotSize = Size(65.0, 65.0);

const double margin = 10.0;

const double bottomDistance = margin * 4;

const int kMaxTooltipLines = 10;

const double kScreenEdgeMargin = 10.0;

const double kTooltipPadding = 5.0;

const Color kTooltipBackgroundColor = Color(0xFF2C3E50);

const Color kHighlightedRenderObjectFillColor = Color.fromARGB(100, 52, 152, 219);

const Color kHighlightedRenderObjectBorderColor = Color.fromARGB(200, 52, 152, 219);

const Color kTipTextColor = Color(0xFFFFFFFF);

final double ratio = bindingAmbiguate(WidgetsBinding.instance)!.window.devicePixelRatio;

final Size windowSize = bindingAmbiguate(WidgetsBinding.instance)!.window.physicalSize / ratio;
