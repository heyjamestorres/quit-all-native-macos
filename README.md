# Quit All Native for macOS

Quit every normal Mac app with one click—without Rosetta. Quit All is a tiny, open-source Apple-silicon utility that closes Finder windows, preserves Finder itself, and always leaves AlDente running.

[Download the latest Apple-silicon build](https://github.com/heyjamestorres/quit-all-native-macos/releases/latest/download/Quit-All-Apple-Silicon.zip)

[Website](https://heyjamestorres.github.io/quit-all-native-macos/) · [Releases](https://github.com/heyjamestorres/quit-all-native-macos/releases)

## What it does

- Sends a normal Quit request, never Force Quit, so apps can ask to save work.
- Closes all Finder windows while leaving the Finder process and desktop running.
- Always preserves AlDente, matched by both bundle identifier and app name.
- Ignores Quit All itself and background or critical system processes.
- Contains no network access, analytics, login item, or persistent helper.
- Runs natively on Apple silicon; Rosetta is not required.

## Requirements

- Apple-silicon Mac (M1 or newer)
- macOS 13 Ventura or newer

## Install

1. Download and unzip `Quit-All-Apple-Silicon.zip` from the latest release.
2. Move **Quit All.app** to Applications or the Dock.
3. Save important work, then click **Quit All** once.

On first use, macOS asks whether Quit All may control Finder. Choose **Allow** so it can close Finder windows. You can change this later under System Settings > Privacy & Security > Automation.

The community build is ad-hoc signed rather than Apple-notarized, so macOS may show an unidentified-developer warning. If it does, Control-click the app, choose **Open**, and then choose **Open** again. Alternatively, use System Settings > Privacy & Security > Open Anyway.

## Build from source

Apple Command Line Tools are sufficient; full Xcode is not required. There are no third-party dependencies.

```sh
chmod +x build.sh
./build.sh
```

The build targets `arm64` and macOS 13 or newer, producing `build/Quit-All-Apple-Silicon.zip`.

## Privacy

Quit All performs its work entirely on your Mac and does not collect or transmit any data. Its complete source is small enough to audit directly.

## License

MIT. See [LICENSE](LICENSE).

This independent project is not affiliated with the makers of other applications named QuitAll.
