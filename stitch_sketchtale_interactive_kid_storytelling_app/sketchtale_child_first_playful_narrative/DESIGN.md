---
name: SketchTale Child-First Playful Narrative
colors:
  surface: '#fbf9f3'
  surface-dim: '#dbdad4'
  surface-bright: '#fbf9f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ee'
  surface-container: '#f0eee8'
  surface-container-high: '#eae8e2'
  surface-container-highest: '#e4e2dd'
  on-surface: '#1b1c19'
  on-surface-variant: '#514532'
  inverse-surface: '#30312d'
  inverse-on-surface: '#f2f1eb'
  outline: '#847560'
  outline-variant: '#d6c4ac'
  surface-tint: '#7e5700'
  primary: '#7e5700'
  on-primary: '#ffffff'
  primary-container: '#ffb300'
  on-primary-container: '#6b4900'
  inverse-primary: '#ffba38'
  secondary: '#ac3509'
  on-secondary: '#ffffff'
  secondary-container: '#fe6f42'
  on-secondary-container: '#631800'
  tertiary: '#006688'
  on-tertiary: '#ffffff'
  tertiary-container: '#64cdff'
  on-tertiary-container: '#005673'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdeac'
  primary-fixed-dim: '#ffba38'
  on-primary-fixed: '#281900'
  on-primary-fixed-variant: '#604100'
  secondary-fixed: '#ffdbd0'
  secondary-fixed-dim: '#ffb59f'
  on-secondary-fixed: '#3a0a00'
  on-secondary-fixed-variant: '#852300'
  tertiary-fixed: '#c2e8ff'
  tertiary-fixed-dim: '#75d1ff'
  on-tertiary-fixed: '#001e2b'
  on-tertiary-fixed-variant: '#004d67'
  background: '#fbf9f3'
  on-background: '#1b1c19'
  surface-variant: '#e4e2dd'
typography:
  headline-xl:
    fontFamily: Quicksand
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.01em
  headline-xl-mobile:
    fontFamily: Quicksand
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Quicksand
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 34px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-lg:
    fontFamily: Quicksand
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Quicksand
    fontSize: 15px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Quicksand
    fontSize: 13px
    fontWeight: '700'
    lineHeight: 18px
    letterSpacing: 0.03em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  touch-min: 3.5rem
  touch-lg: 4.5rem
  gutter-mobile: 1.25rem
  gutter-tablet: 2rem
  margin-page: 1.5rem
  card-gap: 1.25rem
  inset-chunky: 1.25rem
---

## Brand & Style

This design system is engineered specifically for children aged 4–9 engaging in interactive storytelling and creative drawing. The aesthetic balances joyful playfulness, tactile physical metaphors, and high visual accessibility.

### Design Movement & Mood
- **Tactile / Playful Pop:** Inspired by playful, tactile children's media (such as Duolingo ABC, Headspace Kids, and PBS Kids), the interface feels tangible, bouncy, and receptive to curious fingers.
- **Tone:** Welcoming, encouraging, sunny, and forgiving. Interfaces never penalize mis-taps; errors are framed as playful discoveries.
- **Affordance Clarity:** Thick pillowy buttons with pronounced 3D drop-edges (extruded bottom borders), pill-shaped action badges, and chunky cards make tap zones unmistakably interactable for emerging motor skills.

## Colors

The color system delivers high emotional resonance while maintaining strict contrast compliance for developing young eyesight.

### Palette Roles
- **Primary (`#FFB300` - Sunny Honey):** Main call-to-action color, highlight accents, progress sunbursts, and interactive tokens.
- **Secondary (`#FF7043` - Coral Orange):** Joyful secondary actions, energetic badges, character dialogue emphasis, and celebratory banners.
- **Tertiary (`#4FC3F7` - Cheerful Sky Blue):** Narrative backdrops, audio cue indicators, water/sky canvas tools, and navigational badges.
- **Accent Mint (`#66BB6A` - Story Mint):** Positive reinforcement, complete chapter tokens, success states, and audio play triggers.
- **Accent Lilac (`#AB47BC` - Magic Violet):** Wonder, fantasy chapters, stickers, brushes, and creative unlockables.
- **Neutral Background (`#FFFDF7` - Warm Cloud Cream):** Off-white base avoiding harsh glare on tablets and mobile screens while supporting long story sessions.
- **Deep Text Neutral (`#2D261E` - Cocoa Ink):** Warm, deeply pigmented brown-black ensuring maximum readability against soft tints without the harshness of pure `#000000`.

## Typography

Typography prioritizes high phonics legibility, warm open counters, and instantly recognizable letterforms for early and pre-readers.

- **Display & Headings (Quicksand):** Selected for its friendly rounded terminals and geometric clarity. It softens long word shapes and invites reading without intimidation.
- **Narrative & System Body (Plus Jakarta Sans):** Offers balanced proportions, wide x-height, and robust clarity on lower-resolution tablets. Generous line spacing (`1.45x` to `1.55x`) helps eyes track lines effortlessly.
- **Text Sizing:** Base story text starts at `22px` (`body-xl`) to support read-along narration highlights, reducing reading fatigue.

## Layout & Spacing

Interactive elements are scaled for gross motor skills. Tap targets exceed standard adult ergonomics (defaulting to minimum `56px` height, expanding to `72px` for primary story progress buttons).

### Grid & Density
- **Mobile (Phone):** 4-column layout with `20px` gutters and `20px` edge margins. Primary controls sit comfortably within thumb reach in the lower screen third.
- **Tablet / Landscape:** 8-column layout with `32px` gutters. Split screen layout pairs visual picture books on the left (`5 cols`) with interactive drawing/choice pads on the right (`3 cols`).
- **Safe Area Defenses:** Critical story choice buttons maintain at least `24px` clearance from home indicator bars and corner hardware radii.

## Elevation & Depth

Rather than realistic photographic drop shadows, elevation uses tactile **"toy box" physical extrusion**:

1. **3D Press Plates (Physical Buttons):**
   - Active controls have a solid colored border bottom (`4px` to `6px` thicker than the body) in a 25% darker shade of the element's fill color.
   - On tap (`:active`), the button shifts downward by `4px` with the bottom shadow depth collapsing to `0px`, generating instant, satisfying haptic visual feedback.
2. **Cloud Cards:**
   - Surfaces float over the `#FFFDF7` warm backdrop using dual-layer soft ambient shadows: `0px 8px 0px rgba(74, 53, 20, 0.06)` combined with `0px 16px 28px rgba(74, 53, 20, 0.08)`.
3. **Floating Floating Tools & Badges:**
   - Brushes, star rewards, and avatar dialog bubbles incorporate crisp `3px` white outer strokes (`#FFFFFF`) with a subtle directional drop `0 6px 16px rgba(0, 0, 0, 0.1)`.

## Shapes

The design system enforces pillow-soft, ultra-friendly organic shapes. Sharp right angles do not exist within child-accessible story flows.

- **Action Buttons & Badges:** Fully pill-shaped (`9999px`), ensuring no prickly edges and inviting rapid finger taps.
- **Story Scene & Choice Cards:** Deep organic radii (`28px` to `36px`), framing artwork like soft wooden toy blocks.
- **Progress Trackers & Input Trays:** Pill containers with recessed inner shadows that resemble physical pegboard slots.

## Components

### Chunky Action Buttons
- **Style:** Height minimum `56px` (large `64px–72px`). Bold `Quicksand` uppercase or title case typography.
- **Anatomy:** Rich saturated fill (e.g., `#FFB300`), a darker base rim (`border-bottom: 5px solid #E69B00`), and a pill shape (`rounded-full`). 
- **Iconography:** Accompanied by prominent, rounded 28px icons on the leading side.

### Story Choice & Chapter Cards
- **Style:** Rounded `32px` containers with a gentle `2px` boundary stroke in `#F0EAD6`.
- **States:** Selected cards gain a thick `4px` highlight ring in `#4FC3F7` and animate with a cheerful scale punch (`scale: 1.03`).
- **Thumbnail Display:** Generous illustration viewport with masked top corners matching card curvature.

### Interactive Audio Chips & Tags
- **Style:** Pill-shaped tags with mint `#66BB6A` or sky blue `#4FC3F7` fills, white bold labels, and a gentle pulsing waveform icon indicating tap-to-read speech.

### Parent Gate & Settings Inputs
- **Style:** Distinguishable neutral-warm treatment to prevent accidental taps by toddlers. Math challenge dials or hold-to-confirm circles with clear instructional icons.

### Joyful Celebratory Accents
- **Star & Reward Badges:** Golden yellow `#FFB300` stars with thick white strokes, floating alongside dynamic sticker ribbons.
- **Canvas Drawing Toolbars:** Oversized chunky circular tool icons (`60px` diameter) with active pop-out bounce indicators showing currently selected brush or color.