# Udghosh '26 — Theme & User Experience Guide

This document describes the visual design system ("Soft-Neomorphism /
Claymorphism") implemented across the app and walks through how a user
moves through it screen by screen. It's meant as a living reference for
anyone building new screens or components — match the tokens and patterns
here instead of inventing new ones.

Source of truth in code: [`lib/theme/neo_theme.dart`](../lib/theme/neo_theme.dart)
and the shared widgets in [`lib/widgets/neo/`](../lib/widgets/neo/).

---

## 1. Design Philosophy

Soft, tactile, and warm — like a physical sports-day scoreboard rendered in
pillowy plastic. No gradients, no emoji, no harsh drop shadows. Every
surface either **pushes out** (a raised card) or **pushes in** (a recessed
track/field), and that's the only visual vocabulary the whole app uses.

- **Raised surface** — a white card that looks lifted off the mint canvas,
  achieved with a dual shadow pair (a light highlight top-left, a soft dark
  shadow bottom-right).
- **Recessed surface** — a slightly darker, flat neutral fill with a hairline
  border, used for anything the user "reads into" rather than "picks up":
  score tracks, search fields, OTP boxes, segmented-control rails.
- **Floating dock** — the one fully opaque, dark element on screen (the
  bottom nav pill), anchoring the palette and giving the eye a place to rest.

---

## 2. Color Tokens

| Token | Hex | Usage |
|---|---|---|
| `canvasMint` | `#DDF4EE` | App background (default canvas) |
| `canvasCoral` | `#FFEFE8` | Alternate warm background (available, unused by default) |
| `surface` | `#FFFFFF` | Card / raised-surface fill |
| `surfaceRecessed` | `#F0F6F5` | Inset/recessed fill — score tracks, chip rails |
| `logoTeal` | `#0E4B54` | Primary text, headings, active icons |
| `waveTeal` | `#1C91A3` | Secondary accent — icons, links, progress spinners |
| `flameGold` | `#E5B26E` | Highlight accent — active nav pill, "DEMO" tags, result badges |
| `charcoal` | `#1A1D24` | Bottom nav dock, dark CTA buttons |
| `live` (Emerald) | `#10B981` | Live-status dot/pill |
| `alert` (Coral) | `#FF5964` | Errors, logout button, notification badge |
| `textMuted` | `#5C7C7D` | Secondary/body text |
| `onCharcoal` | `#F5F7F7` | Text/icons on the dark dock |

**Shadow pair** (the neomorphic signature — see `NeoShadows.raised()`):
```dart
BoxShadow(color: Colors.white.withOpacity(0.9), offset: Offset(-5, -5), blurRadius: 10)
BoxShadow(color: Color(0x180E4249), offset: Offset(5, 7), blurRadius: 16)
```
A lighter `raisedSmall()` variant (closer offsets, smaller blur) is used for
chips, pills, and circular icon buttons so small elements don't look like
they're floating too far off the canvas.

## 3. Typography

- **Outfit** (via `google_fonts`) — headlines: the "UDGHOSH" wordmark, big
  numbers, section titles.
- **Plus Jakarta Sans** — everything else: body copy, labels, buttons.
- Weight does the talking, not size: `w800` for anything that needs to feel
  "chunky" (scores, CTAs, active nav labels), `w500`–`w600` for body text.

## 4. Shape & Radius

| Token | Value | Used for |
|---|---|---|
| `NeoRadii.card` | 24px | Standard cards |
| `NeoRadii.cardLarge` | 28px | Hero/feature cards |
| `NeoRadii.chip` | 18px | Chips, OTP boxes, inset fields |
| `NeoRadii.pill` | 999px | Buttons, segmented control, status capsules |
| `NeoRadii.dock` | 32px | The floating bottom nav |

## 5. Component Library (`lib/widgets/neo/`)

| Widget | Purpose |
|---|---|
| `NeoCard` | Base raised container — wrap any card content in this |
| `NeoInset` | Recessed container — score tracks, text fields, OTP digits |
| `NeoCircleButton` | 44×44 circular icon button (bell, avatar, back) with optional badge dot |
| `NeoPillButton` | Full-width chunky CTA (SEND OTP, VERIFY & ENTER, LOGOUT) |
| `StatusCapsule` | Small dot+label chip — `● LIVE`, `FINAL` |
| `CustomAppBar` | Persistent top bar: logo mark + wordmark + bell + avatar |
| `NeoBottomNav` | Floating 5-tab pill dock |
| `NeoSegmentedControl` | Sticky [Past]/[Live]/[Upcoming]-style 2–3 way switch |
| `NeoPillBar` | Horizontal scrolling filter/category chips |
| `MatchCard` | Sport-aware scoreboard card (live / upcoming / completed variants) |

---

## 6. Navigation Map

```
DashBoard (persistent CustomAppBar + floating NeoBottomNav)
├─ 0. Home        → HomeScreen
├─ 1. Matches     → MatchesScreen
├─ 2. Gallery     → GalleryScreen
├─ 3. Map         → MapScreen
└─ 4. Other       → OtherScreen
        ├─ push → LoginScreen (if guest)
        └─ push → NoticesScreen
```

The app bar's bell icon and the Other tab's "Announcements & Notices" tile
both push `NoticesScreen`; the avatar button jumps straight to the Other
tab. All five tab bodies live in an `IndexedStack` so switching tabs never
loses scroll position or resets an in-flight network request (e.g. the
Matches screen's 20-second live-score poll keeps ticking in the background).

---

## 7. User Journey, Screen by Screen

### Home
The first thing a user sees. A bold "MATCH HIGHLIGHTS" headline, then the
current top live match as a tappable hero card (tapping it jumps to
Matches). Below that: a horizontal strip of sports currently live
(`cricket · 2`, `football · 1`, …), a row of four quick-action pills
(Campus Map, Standings, Schedule, Notices), and an upcoming-events list.
Pull to refresh reloads everything. If the backend has no live match or no
events yet, exactly one clearly-labelled `DEMO` card is shown instead of an
empty screen.

### Matches
A horizontal pill bar lets the user pick one of the 14 sports. Below it, a
segmented control switches between **Past** (completed results, newest
first), **Live** (auto-refreshes every 20 seconds while this tab is open),
and **Upcoming** (paginated — scrolling near the bottom loads the next page
of 10). Score rendering adapts per sport: cricket shows `runs/wickets (overs)`
for each innings, football/hockey show a goal tally, racquet sports show
discrete set scores, and completed matches highlight the winner. Pull to
refresh re-fetches the active tab.

### Gallery
A 2-column masonry grid of fest photos with a category filter bar (Opening
Night, Athletics, Finals, Pronite). Tapping any photo opens it fullscreen.
Broken/placeholder image URLs from the backend are filtered out
automatically; an empty gallery shows one demo placeholder tile.

### Map
A full interactive campus map (OpenStreetMap tiles) with three rounded
venue badges — Main Stadium, Old SAC, New SAC. Tapping a marker highlights
it and slides in a bottom card previewing that venue's schedule for the day.

### Other (Account & Info Hub)
- **Guest**: a card inviting the user to sign in, with a single
  "LOGIN WITH EMAIL OTP" button leading to the login flow below.
- **Logged in**: an avatar-initial + name + email summary card, and a
  prominent coral "LOGOUT" button at the bottom of the screen that clears
  the session and reverts to guest mode instantly (no confirmation dialog —
  it's a one-tap, low-risk action).
- Below the account card: a link to the full Notices feed, then the
  hardcoded Core Organizing Committee roster grouped by wing (Festival
  Leads, Events, Media & Web Operations), each member shown as a small
  neomorphic card with a placeholder contact icon.

### Login (Email + OTP)
Two steps, one screen, no page transition between them:
1. **Email step** — a single recessed input field and a "SEND OTP" button.
   A small hint under the field: *"Use demo@gmail.com for guest bypass"* —
   typing that address skips the real network call entirely and starts the
   resend cooldown immediately, so the app is fully demoable offline.
2. **OTP step** — six individual recessed digit boxes with auto-advancing
   focus (typing a digit jumps to the next box; deleting jumps back).
   Entering the 6th digit auto-submits. A live countdown
   (*"Resend available in 00:47"*) gates the resend button. Demo bypass:
   `123456` against `demo@gmail.com` logs straight in as **Demo Athlete**.
   Inline error banners surface backend responses in plain language:
   *"Email not registered"* (404), *"Please wait 60s…"* (429), *"Invalid or
   expired OTP"* (401).

---

## 8. Interaction Conventions

- **Haptics**: every tab switch, sport-pill tap, and segmented-control tap
  fires a light haptic (`HapticFeedback.lightImpact` / `selectionClick`) —
  reinforces the "physical button" feel of the claymorphic shapes.
- **Pull to refresh**: available on Home, Matches, Gallery, and Notices.
- **Empty states are never empty**: every list-driven screen renders exactly
  one demo card, clearly tagged `DEMO`, instead of a blank screen or a
  spinner that never resolves.
- **No modals for reversible actions**: logout, tab switches, and filter
  changes apply immediately — modals are reserved for genuinely destructive
  or one-way actions only (none currently exist in this app).
