# SAPI5 TTS Bridge

Windows SAPI5 desktop voice text-to-speech bridge for Hermes Agent.

## What This Does

Converts text to speech using Windows' built-in SAPI5 desktop voices. No API keys, no cloud calls, 100% local and offline.

## Files

- `win-voice-tts.ps1` — PowerShell script that reads text from a file and synthesizes it to WAV audio

## How It Works

1. Hermes sends text to the bridge script via a temp file
2. The script reads the text, selects a voice, and synthesizes speech
3. Output is written as a 16-bit PCM WAV file
4. Hermes delivers the audio to the user

## Available Voices

| Voice | Language | Notes |
|-------|----------|-------|
| Microsoft David Desktop | en-US | System default |
| Microsoft Zira Desktop | en-US | Female, natural |
| Microsoft Hazel Desktop | en-GB | British English |
| Microsoft Sabina Desktop | es-MX | Spanish |
| Microsoft Haruka Desktop | ja-JP | Japanese |
| Microsoft Tracy Desktop | zh-HK | Cantonese |
| Microsoft Hortense Desktop | fr-FR | French |
| Microsoft Heami Desktop | ko-KR | Korean |

## Configuration

```bash
# Configure Hermes to use SAPI5 bridge
hermes config set tts.provider win-voice

# Set default voice (optional)
hermes config set tts.providers.win-voice.voice "Microsoft Zira Desktop"
```

## Usage

### Direct PowerShell
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File win-voice-tts.ps1 `
  -TextPath input.txt `
  -OutPath output.wav `
  -Voice "Microsoft Zira Desktop"
```

### Via Hermes
Just ask the agent to speak something — it will automatically use the bridge.

## Requirements

- Windows 10/11
- PowerShell 5.1 (included with Windows)
- Windows Speech API (SAPI5) — pre-installed

## Limitations

- Desktop voices only (not the newer OneCore natural voices)
- Voices sound dated compared to newer TTS engines
- Requires ffmpeg for voice bubbles on some platforms (optional)

## Troubleshooting

### "voice not found"
- Check voices are installed: Settings → Time & Language → Speech
- Use substring matching: `"Zira"` matches "Microsoft Zira Desktop"

### No ffmpeg
- Install: `scoop install ffmpeg` or `winget install --id Gyan.FFmpeg`

## Testing

```bash
# Test the bridge directly
echo "Hello" > test.txt
powershell -NoProfile -ExecutionPolicy Bypass -File win-voice-tts.ps1 -TextPath test.txt -OutPath test.wav -Voice "Microsoft Zira Desktop"

# Check if output file exists and is non-empty
dir test.wav
```

## License

MIT License — Use freely.
