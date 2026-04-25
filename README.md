# Dikte

Dikte is a native macOS Menu Bar application that seamlessly integrates voice dictation with your clipboard history. It is designed to create a frictionless workflow for interacting with AI assistants (like Claude, ChatGPT, Gemini) by allowing you to talk naturally while copying context (text, links, images). 

## 🚀 Concept & Workflow

When prompting AI, it's common to switch contexts repeatedly: writing a prompt, copying a URL, taking a screenshot, and pasting it all together. **Dikte** eliminates this mental overhead.

1. **Hit the Shortcut** (`⌘⇧Space`) to start recording.
2. **Speak naturally** ("Look at this code here...", "I'm having an issue on this website...").
3. **Copy context** while you speak (copy text, capture screenshots to clipboard, copy URLs).
4. **Hit the Shortcut** again to stop.

Dikte works completely **offline** using Apple's CoreML optimized Whisper models. It transcribes your speech and intelligently interleaves it with the items you copied based on exact timestamps, generating a single, unified Markdown output ready to be pasted to your AI of choice.

## ✨ Features

- **100% Offline & Private:** Uses `WhisperKit` and the `large-v3-turbo` model. No audio or data leaves your device.
- **Smart Clipboard Merging:** Automatically captures `NSPasteboard` events during the recording session and merges them chronologically with your transcribed speech.
- **Image Support:** Screenshots and copied images are automatically saved locally and referenced in the output as Markdown images (`![Ekran Görüntüsü](path)`).
- **Native macOS Experience:** Lightweight Menu Bar app written in SwiftUI.
- **Global Keyboard Shortcut:** Start/Stop from anywhere using `KeyboardShortcuts`.

## 🛠 Prerequisites & Installation

Since Dikte uses `XcodeGen`, the `.xcodeproj` file is generated from `project.yml`. 

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```
2. Generate the project:
   ```bash
   xcodegen generate
   ```
3. Open `Dikte.xcodeproj` and run the app.

> **Note on First Run:** The app will download the `openai_whisper-large-v3_turbo` model (~954 MB) to `~/Library/Application Support/Dikte/Models`. This only happens once.

## 📖 System Architecture

For a deep dive into the underlying services, timestamp logic, and model caching mechanisms, please read the [PROJECT_DETAIL.md](PROJECT_DETAIL.md).
