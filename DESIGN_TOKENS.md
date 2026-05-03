# Campus Connect — Figma Design Tokens
## Team 2: Core Foundation & UI Standards

Use this document to keep Flutter code and Figma in sync.
Every token here has a matching constant in the codebase.

---

## COLOR TOKENS

### Brand
| Token Name            | Hex       | Flutter Constant           |
|-----------------------|-----------|----------------------------|
| `color/brand/primary` | `#4F46E5` | `AppColors.primary`        |
| `color/brand/primary-light` | `#818CF8` | `AppColors.primaryLight` |
| `color/brand/primary-dark`  | `#3730A3` | `AppColors.primaryDark`  |
| `color/brand/accent`  | `#7C3AED` | `AppColors.accent`         |
| `color/brand/accent-light`  | `#A78BFA` | `AppColors.accentLight`  |

### Backgrounds
| Token Name               | Hex       | Flutter Constant            |
|--------------------------|-----------|-----------------------------|
| `color/bg/background`    | `#0A0E27` | `AppColors.background`      |
| `color/bg/surface`       | `#161B40` | `AppColors.surface`         |
| `color/bg/surface-high`  | `#1E2554` | `AppColors.surfaceHigher`   |
| `color/bg/bottom-nav`    | `#0D1133` | `AppColors.bottomNav`       |

### Text
| Token Name               | Hex       | Flutter Constant            |
|--------------------------|-----------|-----------------------------|
| `color/text/primary`     | `#FFFFFF` | `AppColors.textPrimary`     |
| `color/text/secondary`   | `#B0B8D4` | `AppColors.textSecondary`   |
| `color/text/hint`        | `#596088` | `AppColors.textHint`        |

### Semantic
| Token Name               | Hex       | Flutter Constant            |
|--------------------------|-----------|-----------------------------|
| `color/semantic/success` | `#10B981` | `AppColors.success`         |
| `color/semantic/warning` | `#F59E0B` | `AppColors.warning`         |
| `color/semantic/error`   | `#EF4444` | `AppColors.error`           |
| `color/semantic/info`    | `#38BDF8` | `AppColors.info`            |

### Borders
| Token Name               | Hex / Opacity | Flutter Constant        |
|--------------------------|---------------|-------------------------|
| `color/border/default`   | `#FFFFFF 12%` | `AppColors.border`      |
| `color/border/focus`     | `#4F46E5`     | `AppColors.borderFocus` |
| `color/border/divider`   | `#FFFFFF 6%`  | `AppColors.divider`     |

---

## SPACING TOKENS

| Token Name       | Value   | Flutter Constant          |
|------------------|---------|---------------------------|
| `spacing/xs`     | `4px`   | `AppSpacing.xs`           |
| `spacing/sm`     | `8px`   | `AppSpacing.sm`           |
| `spacing/md`     | `12px`  | `AppSpacing.md`           |
| `spacing/lg`     | `16px`  | `AppSpacing.lg`           |
| `spacing/xl`     | `20px`  | `AppSpacing.xl`           |
| `spacing/2xl`    | `24px`  | `AppSpacing.xl2`          |
| `spacing/3xl`    | `32px`  | `AppSpacing.xl3`          |
| `spacing/screen` | `16px`  | `AppSpacing.screenPadding`|
| `spacing/card`   | `16px`  | `AppSpacing.cardPadding`  |

---

## BORDER RADIUS TOKENS

| Token Name         | Value   | Flutter Constant   |
|--------------------|---------|--------------------|
| `radius/xs`        | `4px`   | `AppRadius.xs`     |
| `radius/sm`        | `8px`   | `AppRadius.sm`     |
| `radius/md`        | `12px`  | `AppRadius.md`     |
| `radius/lg`        | `16px`  | `AppRadius.lg`     |
| `radius/xl`        | `20px`  | `AppRadius.xl`     |
| `radius/2xl`       | `24px`  | `AppRadius.xxl`    |
| `radius/full`      | `999px` | `AppRadius.full`   |

---

## TYPOGRAPHY TOKENS

Font family: **Inter** (Google Fonts)

| Token Name            | Size | Weight | Flutter Constant          |
|-----------------------|------|--------|---------------------------|
| `type/display`        | 32   | 700    | `AppTextStyles.display`   |
| `type/h1`             | 24   | 600    | `AppTextStyles.h1`        |
| `type/h2`             | 20   | 600    | `AppTextStyles.h2`        |
| `type/h3`             | 17   | 600    | `AppTextStyles.h3`        |
| `type/body-lg`        | 16   | 400    | `AppTextStyles.bodyLg`    |
| `type/body-md`        | 14   | 400    | `AppTextStyles.bodyMd`    |
| `type/body-sm`        | 12   | 400    | `AppTextStyles.bodySm`    |
| `type/label-lg`       | 14   | 500    | `AppTextStyles.labelLg`   |
| `type/label-md`       | 12   | 500    | `AppTextStyles.labelMd`   |
| `type/button`         | 15   | 600    | `AppTextStyles.button`    |
| `type/nav-label`      | 10   | 500    | `AppTextStyles.navLabel`  |
| `type/caption`        | 11   | 400    | `AppTextStyles.caption`   |

---

## COMPONENT SIZES

| Component             | Height  | Notes                          |
|-----------------------|---------|--------------------------------|
| Button (primary)      | `52px`  | Full-width by default          |
| Input field           | `52px`  | 16px horizontal padding        |
| Search bar            | `48px`  | Leading search icon            |
| Bottom nav bar        | `64px`  | + SafeArea bottom inset        |
| Avatar (default)      | `40px`  | Circle, 40×40                  |
| Card border           | `0.5px` | `AppColors.border`             |

---

## HOW TO USE IN FIGMA

1. Install the **Tokens Studio** Figma plugin
2. Import `figma_tokens.json` (ask Team 2 for this file)
3. All color, spacing, and type styles will auto-populate
4. Name your components to match the Flutter widget names:
    - `CCPrimaryButton`, `CCSecondaryButton`, `CCCard`, etc.
5. Use **Auto Layout** with the spacing tokens above
6. Export measurements using **Dev Mode** — they match Flutter exactly

---

## GRADIENT SPECS

### Primary Gradient (hero CTAs, avatars)
- Direction: 135° (top-left → bottom-right)
- Stop 1: `#4F46E5` (0%)
- Stop 2: `#7C3AED` (100%)

### Card Gradient (premium cards)
- Direction: 135°
- Stop 1: `#1E2554` (0%)
- Stop 2: `#161B40` (100%)

---

*Last updated: April 2026 — Team 2 Campus Connect*
