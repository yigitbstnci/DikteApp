# Dikte

Dikte is a privacy-first macOS menu bar app for preparing rich AI prompts with voice and clipboard context.

It lets you speak naturally while copying related material from other apps. When recording stops, Dikte transcribes your speech locally, places copied items into the right moment in the transcript, and copies one Markdown output back to your clipboard.

## How It Works

1. Press `Command + Shift + Space` to start recording.
2. Speak your prompt or explanation.
3. Copy context while speaking, such as text, links, or screenshots.
4. Press `Command + Shift + Space` again to stop.
5. Paste the generated Markdown into ChatGPT, Claude, Gemini, or another assistant.

## Privacy Model

- Speech-to-text runs locally through WhisperKit.
- Audio and clipboard data are not sent to a cloud transcription service.
- The Whisper model is stored locally after the first download.
- Copied text and images are saved locally so they can be referenced in the final output.

Local storage paths:

```text
~/Library/Application Support/Dikte/Models
~/Library/Application Support/Dikte/ClipboardAssets
```

## Output Shape

Dikte produces a transcript with numbered inline references and an attachments section:

```text
Bu ekrandaki problemi anlatıyorum. ¹ Bir de ilgili dokümandaki şu kısmı kontrol et. ²

Attachments

1  /Users/example/Library/Application Support/Dikte/ClipboardAssets/clipboard_123.png [CleanShot X] (1.2 MB)
2  https://example.com/docs [Safari] (128 B)
```

## Current Scope

The current app focuses on:

- menu bar recording control,
- floating HUD feedback,
- global keyboard shortcut,
- local Whisper transcription,
- clipboard capture during recording,
- timestamp-based transcript and attachment merging,
- automatic copy-to-clipboard after processing.

Planned improvement areas include real settings persistence, first-run model download onboarding, stronger tests, and more robust output customization.
