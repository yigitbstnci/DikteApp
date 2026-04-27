# Dikte: Fluid Zen Edition

## Product Overview

**The Pitch:** Dikte is a privacy-first, on-device macOS Menu Bar app that transforms voice into perfectly formatted Markdown. It combines the tactile satisfaction of native Apple interfaces with fluid, organic visual feedback to make dictation feel magical and effortless.

**For:** Writers, developers, and thinkers who need zero-friction, context-aware voice capture without relying on cloud APIs.

**Device:** desktop (macOS Menu Bar / Desktop app)

**Design Direction:** "Fluid Zen" – Deeply native macOS Sonoma aesthetic injected with organic warmth. Heavy use of background blur (`backdrop-filter`), soft mesh gradients for active states, rounded typography, and liquid-like animations for audio waveforms.

**Inspired by:** Apple Siri (iOS 17 fluid blob), Raycast (snappiness and native feel), Bear (typography and markdown focus).

---

## Screens

- **Menu Bar Popover:** Quick-access recording interface with fluid states (Idle, Recording, Processing, Success).
- **Settings - General & Output:** Native-style preferences window managing launch behavior and markdown export paths.
- **Settings - Language & Model:** Configuration for local LLM weights and dictation languages.
- **Onboarding / Model Download:** First-launch experience with progress indicators for downloading local AI models.

---

## Key Flows

**Dictation Capture Flow:** The core loop of capturing a thought.

1. User is on **Any App** -> presses global shortcut (`⌘ + ⇧ + Space`)
2. User sees **Menu Bar Popover (Idle)** -> immediately transitions to **Recording** state
3. User speaks -> sees organic, fluid mesh gradient waveform reacting to voice
4. User clicks **Stop** (or presses `Esc`) -> enters **Processing** state with liquid loading spinner
5. **Result:** Success state flashes briefly, markdown is copied to clipboard, popover dismisses.

---

<details>
<summary>Design System</summary>

## Color Palette

Focusing on a "Dark Zen" macOS theme. All backgrounds rely on glassmorphism.

- **Primary:** `#5E5CE6` - Core accent (macOS Indigo)
- **Gradient Accent:** `#32ADE6` - Used with Primary for fluid mesh gradients
- **Background:** `rgba(28, 28, 30, 0.65)` - Translucent macOS dark panel
- **Surface:** `rgba(44, 44, 46, 0.5)` - Hover states, input fields, inner cards
- **Text:** `#FFFFFF` - Primary body and headings
- **Muted:** `#EBEBF5` (Opacity 60%) - Secondary text, placeholders, subtle borders
- **Accent/Success:** `#30D158` - Completion checkmarks, copy success

## Typography

Using Apple's rounded system font to soften the technical nature of voice-to-text.

- **Headings:** `SF Pro Rounded`, 600, 20px, tight tracking (-0.5px)
- **Body:** `SF Pro Rounded`, 400, 14px
- **Small text:** `SF Pro Rounded`, 500, 12px
- **Buttons:** `SF Pro Text`, 500, 13px (Standard macOS control size)

**Style notes:** 
- **Glassmorphism:** `backdrop-filter: blur(40px) saturate(180%)` on all main panels.
- **Shadows:** Deep, soft shadows `0 10px 40px rgba(0,0,0,0.3)` with a crisp `1px` inner white border (`rgba(255,255,255,0.1)`) to simulate physical glass edges.
- **Radii:** `18px` for main popover, `6px` for internal buttons/inputs.

## Design Tokens

```css
:root {
  --color-primary: #5E5CE6;
  --color-gradient-accent: #32ADE6;
  --color-bg-glass: rgba(28, 28, 30, 0.65);
  --color-surface-glass: rgba(44, 44, 46, 0.5);
  --color-text-primary: #FFFFFF;
  --color-text-muted: rgba(235, 235, 245, 0.6);
  --color-success: #30D158;
  --color-border: rgba(255, 255, 255, 0.1);
  
  --font-primary: ui-rounded, 'SF Pro Rounded', system-ui, sans-serif;
  --font-ui: system-ui, 'SF Pro Text', sans-serif;
  
  --radius-panel: 18px;
  --radius-control: 6px;
  
  --shadow-glass: 0 10px 40px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.1);
  --blur-heavy: blur(40px) saturate(180%);
}
```

</details>

---

<details>
<summary>Screen Specifications</summary>

### Menu Bar Popover

**Purpose:** The primary interface for dictation, attached to the macOS menu bar.

**Layout:** Compact vertical card (320px width), centered content, floating near the top right of the screen.

**Key Elements:**
- **Status Ring:** 120px circular visualization. Idle: subtle glow. Recording: active mesh gradient (`#5E5CE6` to `#32ADE6`) morphing via CSS animations.
- **Time Indicator:** 14px `SF Pro Rounded`, centered inside the ring, monospaced numbers `00:00`.
- **Context Toggle:** 24px height pill button at bottom. `rgba(44, 44, 46, 0.5)` background. Reads "Capture Context" (grabs active window text).

**States:**
- **Idle:** Greyed out microphone icon (`SF Symbol: mic.fill`), muted text.
- **Recording:** Liquid gradient blob expands/contracts with simulated audio volume.
- **Processing:** Blob spins and condenses into a glowing dot. Text reads "Transcribing locally..."
- **Success:** Green checkmark (`SF Symbol: checkmark.circle.fill`), text "Copied to Clipboard".

**Components:**
- **Primary Action Area:** 320x240px, full glass background, `18px` radius.

**Interactions:**
- **Click Status Ring:** Toggles start/stop recording. Smooth `scale(0.95)` on `mousedown`.
- **Hover Context Toggle:** Background shifts to `rgba(255,255,255,0.1)`, cursor defaults.

### Settings Window

**Purpose:** Native macOS preferences multi-tab window.

**Layout:** Sidebar left (160px), Content right (440px). Total 600x400px.

**Key Elements:**
- **Sidebar Tabs:** General, Language, Output. 13px `SF Pro Text`, 5px padding, 6px radius.
- **Form Controls:** macOS-style dropdowns (24px height, blue focus ring), toggle switches (green when active).
- **Model Selector:** Dropdown for "Whisper Base", "Whisper Small". Shows subtext for RAM usage.

**States:**
- **Loading:** Gray skeleton pulses `rgba(255,255,255,0.05)` when checking for model updates.

**Components:**
- **Preference Row:** Horizontal flexbox, label left (`13px`, `#FFF`), control right. 16px bottom margin.

**Interactions:**
- **Click Tab:** Instantly swaps right panel content, active tab gets `rgba(255,255,255,0.1)` background.

### Onboarding / Model Download

**Purpose:** First-time setup, downloading heavy LLM weights locally.

**Layout:** Centered modal, 480x320px.

**Key Elements:**
- **Hero Icon:** Large 48px SF Symbol (`brain.head.profile`), subtle Indigo glow.
- **Title:** "Preparing Local Intelligence", 24px, 600 weight.
- **Progress Bar:** 8px height, full width of container. Track: `rgba(255,255,255,0.1)`. Fill: `#5E5CE6` transitioning to `#32ADE6`.
- **Detail Text:** "Downloading Whisper-Base (142 MB / 450 MB)", 12px, Muted.

**States:**
- **Downloading:** Progress bar animates width.
- **Complete:** Progress bar disappears, replaced by a primary "Start Dictating" button.

**Interactions:**
- **Hover Button:** Opacity 1.0 to 0.9.

</details>

---

<details>
<summary>Build Guide</summary>

**Stack:** HTML + Tailwind CSS v3 (Arbitrary values heavily used for glassmorphism and specific macOS dimensions).

**Build Order:**
1. **Menu Bar Popover (Idle & Recording)** - Establishes the core glassmorphism classes, the mesh gradient animation (requires custom CSS keyframes in Tailwind config), and the SF Pro Rounded typography layer.
2. **Settings Window** - Builds the complex macOS form controls (toggles, selects) and layout structure which can be reused in future views.
3. **Onboarding / Model Download** - Reuses the panel styles from the Settings window but incorporates the progress visualizations and typography established in the Popover.

**Tailwind Extensions needed:**
```javascript
theme: {
  extend: {
    animation: {
      'fluid-blob': 'blob 8s infinite ease-in-out',
    },
    keyframes: {
      blob: {
        '0%, 100%': { borderRadius: '60% 40% 30% 70% / 60% 30% 70% 40%' },
        '50%': { borderRadius: '30% 70% 70% 30% / 50% 60% 30% 60%' }
      }
    }
  }
}
```

</details>
