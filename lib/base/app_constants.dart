import 'package:flutter/material.dart';

/// Campus Connect — Spacing & Sizing Constants
/// Team 2: Core Foundation & UI Standards
///
/// Use these everywhere instead of raw doubles so the entire team
/// stays consistent. Changing one value here updates the whole app.

class AppSpacing {
  AppSpacing._();

  // ── Base 4-pt Grid ───────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
  static const double xl6 = 64.0;

  // ── Semantic Shortcuts ───────────────────────────────────────
  static const double screenPadding  = lg;
  static const double cardPadding    = lg;
  static const double sectionGap     = xl2;
  static const double itemGap        = md;
  static const double inputHeight    = 52.0;
  static const double buttonHeight   = 52.0;
  static const double navBarHeight   = 72.0;

  // ── EdgeInsets Helpers ───────────────────────────────────────
  static const EdgeInsets screenInsets    = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets cardInsets      = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardInsetsH     = EdgeInsets.symmetric(horizontal: cardPadding, vertical: md);
  static const EdgeInsets buttonInsets    = EdgeInsets.symmetric(horizontal: xl2, vertical: 15);
  static const EdgeInsets chipInsets      = EdgeInsets.symmetric(horizontal: md, vertical: xs + 2);
  static const EdgeInsets listTileInsets  = EdgeInsets.symmetric(horizontal: lg, vertical: md);
}

class AppRadius {
  AppRadius._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;  // pill shape

  // ── BorderRadius Helpers ─────────────────────────────────────
  static final BorderRadius card     = BorderRadius.circular(lg);
  static final BorderRadius input    = BorderRadius.circular(md);
  static final BorderRadius button   = BorderRadius.circular(md);
  static final BorderRadius chip     = BorderRadius.circular(full);
  static final BorderRadius badge    = BorderRadius.circular(full);
  static final BorderRadius modal    = const BorderRadius.vertical(top: Radius.circular(xxl));
  static final BorderRadius avatar   = BorderRadius.circular(full);
}
