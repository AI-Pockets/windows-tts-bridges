using System;
using System.IO;
using Windows.Media.SpeechSynthesis;
using Windows.Storage.Streams;
using System.Runtime.InteropServices.WindowsRuntime; // AsStreamForRead / ToArray extensions

class Program
{
    static int Main(string[] args)
    {
        try
        {
            if (args.Length >= 1 && args[0] == "list")
            {
                foreach (var v in SpeechSynthesizer.AllVoices)
                    Console.WriteLine($"{v.DisplayName}\t{v.Language}");
                return 0;
            }
            if (args.Length < 2)
            {
                Console.Error.WriteLine("usage: winrt-tts <text-file> <out-file> [voice-substring]");
                return 2;
            }
            string text = File.ReadAllText(args[0]);
            string outPath = args[1];
            string voiceName = args.Length > 2 ? args[2] : "";

            var synth = new SpeechSynthesizer();
            try
            {
                if (!string.IsNullOrEmpty(voiceName))
                {
                    VoiceInformation match = null;
                    foreach (var v in SpeechSynthesizer.AllVoices)
                        if (v.DisplayName.Contains(voiceName, StringComparison.OrdinalIgnoreCase)) { match = v; break; }
                    if (match == null)
                    {
                        var avail = new System.Collections.Generic.List<string>();
                        foreach (var v in SpeechSynthesizer.AllVoices) avail.Add(v.DisplayName);
                        Console.Error.WriteLine($"voice not found: {voiceName}. Available: {string.Join(", ", avail)}");
                        return 3;
                    }
                    synth.Voice = match;
                }

                // SynthesizeTextToStreamAsync returns a SpeechSynthesisStream (an IRandomAccessStream).
                var stream = synth.SynthesizeTextToStreamAsync(text).AsTask().GetAwaiter().GetResult();
                if (stream.Size == 0) throw new Exception("synth produced an empty stream");

                // Drain via the WinRT projection's AsStreamForRead() -> a normal .NET Stream.
                using (var netStream = stream.AsStreamForRead())
                {
                    var ms = new MemoryStream();
                    netStream.CopyTo(ms);
                    byte[] bytes = ms.ToArray();
                    if (File.Exists(outPath)) File.Delete(outPath);
                    File.WriteAllBytes(outPath, bytes);
                    Console.WriteLine($"WROTE {outPath} ({bytes.Length} bytes)");
                }
            }
            finally { synth.Dispose(); }
            return 0;
        }
        catch (Exception e)
        {
            Console.Error.WriteLine("winrt-tts failed: " + e.Message);
            return 1;
        }
    }
}
