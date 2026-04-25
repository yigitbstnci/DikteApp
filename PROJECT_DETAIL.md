# Dikte - Project Details & Architecture

This document serves as the technical reference for the Dikte project. Read this to quickly understand the codebase structure, design decisions, and how the core mechanics work without having to read every line of code.

## 🏗 Directory Structure

The project is driven by `XcodeGen` (`project.yml`) which defines a pure Swift codebase without the clutter of a tracked `.xcodeproj` file. 

```
Sources/
├── DikteApp.swift                  // App Entry Point (NSApplicationDelegateAdaptor)
├── AppState.swift                  // Central State Manager (@Observable)
├── Views/                          // SwiftUI UI Components
│   ├── MenuBarView.swift           // Main Popover UI
│   └── SettingsView.swift          // (Placeholder for future settings)
├── Models/                         // Data Structures
│   ├── RecordingSession.swift      // Represents a complete dictation + clipboard session
│   └── ClipboardItem.swift         // Text/URL/Image copied during recording
└── Services/                       // Core Logic
    ├── AudioRecorderService.swift  // Microphone capture via AVAudioEngine
    ├── TranscriptionService.swift  // STT via WhisperKit
    ├── ClipboardMonitorService.swift // Tracks NSPasteboard events
    └── MergerService.swift         // Algorithm to weave text & clipboard items
```

## 🧠 Core Services Breakdown

### 1. AudioRecorderService
- **Mechanism:** Uses `AVAudioEngine` and `AVAudioFile` to stream microphone input (`bus 0`) directly into a `.wav` file stored in the temporary directory.
- **Timestamping:** Captures the exact `Date()` when `engine.start()` is called. This `recordingStartTime` is critical, as it serves as the "Time Zero" anchor (T=0.0s) for syncing with clipboard events.

### 2. ClipboardMonitorService
- **Mechanism:** Periodically polls `NSPasteboard.general.changeCount` every 0.5 seconds using a `Timer`.
- **Handling Items:** 
  - *Text/URLs:* Extracted as raw strings.
  - *Images:* Extracted as TIFF data, converted to PNG, and saved to `/tmp/dikte_clipboard_images/`. The item's value becomes a Markdown image reference `![Ekran Görüntüsü](file:///path/to/image.png)`.
- **Timestamping:** When a change is detected, it calculates the offset from `recordingStartTime` (e.g., if copied 4.2 seconds after recording started, its offset is `4.2`).

### 3. TranscriptionService
- **AI Model:** Uses `WhisperKit` with the `openai_whisper-large-v3_turbo` model. This specific model was chosen as it provides the best balance of speed and accuracy for the Turkish language.
- **Persistence:** To avoid re-downloading the ~954MB model, it is persisted to `~/Library/Application Support/Dikte/Models`.
- **Caching:** The `WhisperKit` instance is initialized once on app launch (`preload()`) and kept in memory to eliminate loading times on subsequent recordings.
- **Decoding Options:** `language: "tr"` (skips language detection), `wordTimestamps: true` (critical for accurate merging), and `suppressBlank: true`.
- **Sanitization:** Raw Whisper outputs often contain special tokens (e.g., `<|startoftranscript|>`) or Turkish-specific hallucinations (e.g., "Altyazı M.K.", "Çeviri:"). A custom regex and replace function (`cleanTranscriptText`) strips these out.

### 4. MergerService
- **The Algorithm:** This service takes the `[TranscriptSegment]` (from Whisper) and `[ClipboardItem]` (from Pasteboard) and weaves them together.
- **Logic:** 
  - It iterates through the text segments. 
  - If a clipboard item's timestamp falls between a segment's start and end time (or slightly after it), it injects the clipboard item into the text at that exact moment.
  - This simulates the user saying "Look at this..." -> *User copies item* -> "...how do I fix it?".

## 🔒 Permissions & Entitlements
Because the app interacts with system-wide hardware and state:
1. **Microphone:** `NSMicrophoneUsageDescription` in `Info.plist`.
2. **Clipboard / App Sandbox:** The App Sandbox (`com.apple.security.app-sandbox`) is intentionally set to `NO` (or omitted) in `Dikte.entitlements`. If the app was sandboxed, it wouldn't be able to read the global pasteboard contents from other apps.

## 🚀 Future Roadmap & Next Steps
- Implement robust settings (Change shortcut, change language, change save destination).
- Add functionality to automatically paste the merged result into the active application.
- UI Polish (Hover effects, dark mode optimization, processing animations).
