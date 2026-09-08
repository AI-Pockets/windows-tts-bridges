# Windows Voice TTS Bridges for Hermes Agent

**Two local, offline text-to-speech bridges for Windows — no API keys, nothing leaves your PC.**

## 🎯 What Are These?

These are **command provider bridges** that let Hermes Agent use Windows' built-in speech synthesis engines for text-to-speech (TTS). Both bridges are **100% local and offline** — no cloud calls, no accounts, no API keys.

| Bridge | Engine | Voices | Quality | Setup |
|--------|--------|--------|---------|-------|
| **SAPI5** | Desktop voices | 8 voices | Good | PowerShell script (no build needed) |
| **OneCore** | Natural voices | 21+ voices | Excellent | C# executable (pre-compiled) |

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- Hermes Agent installed
- .NET 9 SDK (for OneCore bridge, optional — exe is pre-compiled)

### Installation

#### Option 1: One-Core Bridge (Recommended)
The pre-compiled executable is included. Just configure Hermes:

```bash
# Configure Hermes to use the OneCore bridge
hermes config set tts.provider win-voice
```

The bridge is already configured in the default config. No additional setup needed!

#### Option 2: SAPI5 Bridge
Already working out of the box. Just configure:

```bash
hermes config set tts.provider win-voice
```

### Configuration

Edit `config.yaml` or use the CLI:

```bash
# Set default voice
hermes config set tts.providers.win-voice.voice "Microsoft Zira Desktop"

# Or set to OneCore voice
hermes config set tts.providers.win-voice.voice "Susan"

# Clear to use system default
hermes config unset tts.providers.win-voice.voice
```

## 📁 Repository Structure

```
sapi5-bridge/
└── win-voice-tts.ps1    # PowerShell script for SAPI5 voices

winrt-bridge/
├── winrt-tts.csproj     # .NET 9 project file
└── Program.cs           # C# source code
```

**Pre-compiled executable:** `winrt-tts.exe` is included in the repository root.

## 🎤 Available Voices

### SAPI5 Desktop Voices
- **Microsoft David Desktop** (en-US) — System default
- **Microsoft Zira Desktop** (en-US) — Female, natural
- **Microsoft Hazel Desktop** (en-GB) — British English
- **Microsoft Sabina Desktop** (es-MX) — Spanish
- **Microsoft Haruka Desktop** (ja-JP) — Japanese
- **Microsoft Tracy Desktop** (zh-HK) — Cantonese
- **Microsoft Hortense Desktop** (fr-FR) — French
- **Microsoft Heami Desktop** (ko-KR) — Korean

### OneCore Natural Voices (21+)
- **Susan** (en-GB) — British English, natural
- **George** (en-GB) — British English, male
- **Mark** (en-US) — American English, natural
- **Holly** (en-AU) — Australian English
- **Dora** (en-IN) — Indian English
- **Nancy** (en-US) — American English, female
- **Plus 18 more...** (see `winrt-tts.exe list`)

## 🛠️ Usage Examples

### Via Hermes Agent (Recommended)
Just ask the agent to speak something:

```
Agent: "Use the text_to_speech tool to say: Hello, this is a test!"
```

### Direct PowerShell (SAPI5)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File win-voice-tts.ps1 `
  -TextPath input.txt `
  -OutPath output.wav `
  -Voice "Microsoft Zira Desktop"
```

### Direct Command Line (OneCore)
```cmd
winrt-tts.exe input.txt output.wav "Susan"
```

### List Available Voices
```cmd
winrt-tts.exe list
```

## 📋 Configuration Reference

### config.yaml Structure
```yaml
tts:
  provider: win-voice  # or "edge", "openai", "gemini", etc.
  providers:
    win-voice:
      command: "C:\Path\to\winrt-tts.exe {text_path} {output_path} {voice}"
      format: wav
      voice_compatible: true
      timeout: 60
      voice: "Susan"  # Optional: set default voice
```

### Placeholder Values
| Placeholder | Meaning |
|-------------|---------|
| `{text_path}` | Path to text file (UTF-8) |
| `{output_path}` | Where to write the audio file |
| `{voice}` | Voice name or substring |

## 🔧 Troubleshooting

### "voice not found"
- Check that the voice is installed: Settings → Time & Language → Speech
- Use substring matching: `"Sus"` matches "Susan"
- List voices: `winrt-tts.exe list`

### "no ffmpeg" / "audio delivery"
- WAV files need ffmpeg for voice bubbles on some platforms
- Install: `scoop install ffmpeg` or `winget install --id Gyan.FFmpeg`

### "exit code 1"
- Check that .NET 9 SDK is installed (for OneCore bridge)
- Verify the exe path in config.yaml matches your location

### "PowerShell 5.1 only"
- The SAPI5 script requires PowerShell 5.1 (included with Windows)
- No PS7 cmdlets needed

## 🏗️ Building from Source (OneCore)

### Prerequisites
- .NET 9 SDK
- Windows 10/11

### Build Steps
```powershell
# Install .NET 9 SDK (if not already installed)
dotnet --version  # Should show 9.x.x

# Build the project
cd winrt-bridge
dotnet build -c Release
dotnet publish -c Release -r win-x64 --self-contained false -o publish

# The exe will be in: winrt-bridge/publish/winrt-tts.exe
```

### Verify Installation
```cmd
winrt-tts.exe list
```

## 📖 Documentation

- **SAPI5 Bridge:** See `sapi5-bridge/README.md`
- **OneCore Bridge:** See `winrt-bridge/README.md`
- **Hermes TTS Configuration:** See Hermes documentation

## 🌟 Features

✅ **100% Local** — No cloud calls, no API keys, no accounts  
✅ **Offline** — Works without internet connection  
✅ **High Quality** — OneCore voices sound natural and modern  
✅ **Easy Setup** — Pre-compiled executable, no build needed  
✅ **Configurable** — Choose voices, speed, format  
✅ **Cross-Platform Hermes** — Works with Hermes on any platform  

## 📝 License

MIT License — Use freely for personal and commercial projects.

## 🤝 Contributing

Contributions welcome! If you find a bug, have a suggestion, or want to add new voices, please open an issue or submit a pull request.

## 🙏 Acknowledgments

- Microsoft for the excellent Windows Speech APIs
- Hermes Agent for the command provider system
- The Windows community for contributing voices

---

**Made with ❤️ for the local-first AI community**
