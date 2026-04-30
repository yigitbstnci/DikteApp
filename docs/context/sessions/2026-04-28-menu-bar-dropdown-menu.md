# Menu Bar Dropdown Menu

## Goal

Replace the large custom menu bar popover with a native macOS dropdown menu.

## Changes

- Changed `MenuBarExtra` from window style to menu style.
- Reworked `MenuBarView` into native menu content with status text, `Kayıt` and `Pano` submenus, settings, and quit actions.
- Preserved the existing settings-open diagnostic log event.
- Updated current project state to record the native dropdown behavior.

## Verification

- `make test` completed successfully.

## Follow-ups

- Validate the exact menu item ordering during live app use and adjust labels if needed.
