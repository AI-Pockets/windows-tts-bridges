# win-voice-tts.ps1 — Bridge Hermes TTS to the built-in Windows SAPI5 voices.
#
# Reads UTF-8 text from -TextPath, synthesizes with the selected (or system
# default) installed voice, writes a 16-bit PCM WAV to -OutPath.
# Exit code: 0 on success; non-zero + stderr message on failure.
#
# Direct usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File win-voice-tts.ps1 `
#     -TextPath in.txt -OutPath out.wav [-Voice "Microsoft Zira Desktop"] [-Rate 1.2]
#
# Hermes wiring (already configured on this machine — see config.yaml):
#   tts:
#     provider: win-voice
#     providers:
#       win-voice:
#         command: powershell -NoProfile -ExecutionPolicy Bypass -File $LOCALAPPDATA/hermes/bin/win-voice-tts.ps1 -TextPath {text_path} -OutPath {output_path} -Voice {voice}
#         format: wav
#         voice_compatible: true
#         timeout: 60
#   Switch default voice: hermes config set tts.providers.win-voice.voice "Microsoft Zira Desktop"
#   (Empty/unset voice = Windows system default. Voice selection is config-driven —
#    the {voice} placeholder in the command template reads that key.)
#
# List installed voices:
#   powershell -NoProfile -Command "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }"
#
# Notes: PowerShell 5.1 compatible. SAPI owns the output file handle
# (SetOutputToWaveFile) — do not wrap it in manual stream disposal.

param(
    [Parameter(Mandatory=$true)][string]$TextPath,
    [Parameter(Mandatory=$true)][string]$OutPath,
    [string]$Voice = "",
    [string]$Rate  = ""   # optional Hermes speed multiplier (e.g. "1.2")
)

$ErrorActionPreference = "Stop"

function Fail([string]$msg) {
    Write-Error $msg
    exit 1
}

try {
    if (-not (Test-Path -LiteralPath $TextPath)) { Fail "text file not found: $TextPath" }
    $dir = Split-Path -Parent $OutPath
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    Add-Type -AssemblyName System.Speech
} catch {
    Fail "failed to load System.Speech: $($_.Exception.Message)"
}

$text = [System.IO.File]::ReadAllText($TextPath, [System.Text.Encoding]::UTF8)
if ([string]::IsNullOrWhiteSpace($text)) { Fail "input text is empty" }

$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
try {
    if ($Voice) {
        # Exact name first; fall back to case-insensitive substring match.
        $exact = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Name -eq $Voice }
        if (-not $exact) {
            $match = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Name.ToLower().Contains($Voice.ToLower()) } | Select-Object -First 1
            if ($match) { $Voice = $match.VoiceInfo.Name } else {
                Fail "voice '$Voice' not found. Installed voices: $(($synth.GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }) -join ' | ')"
            }
        }
        $synth.SelectVoice($Voice)
    }

    if ($Rate) {
        try {
            $speed = [double]$Rate
            $rate  = [int][Math]::Round(($speed - 1.0) * 10)
            if ($rate -gt  10) { $rate =  10 }
            if ($rate -lt -10) { $rate = -10 }
            $synth.Rate = $rate
        } catch {
            # Non-numeric speed value — ignore and use the voice's default rate.
        }
    }

    # SetOutputToWaveFile manages the file handle itself — no stream juggling.
    if (Test-Path -LiteralPath $OutPath) { Remove-Item -LiteralPath $OutPath -Force }
    $synth.SetOutputToWaveFile($OutPath)
    $synth.Speak($text)

    if (-not (Test-Path -LiteralPath $OutPath)) { Fail "no output file written" }
    $size = (Get-Item -LiteralPath $OutPath).Length
    if ($size -le 44) { Fail "output WAV is empty or truncated ($size bytes)" }
} finally {
    try { $synth.Dispose() } catch { }
}

exit 0
