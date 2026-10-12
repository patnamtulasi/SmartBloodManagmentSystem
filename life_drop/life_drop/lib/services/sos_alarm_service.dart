import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

/// Generates and plays a pulsing emergency siren tone for SOS alerts.
/// Uses programmatically generated WAV audio — no external asset files needed.
class SOSAlarmService {
  static final SOSAlarmService _instance = SOSAlarmService._();
  factory SOSAlarmService() => _instance;
  SOSAlarmService._();

  AudioPlayer? _player;
  Timer? _stopTimer;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Plays an emergency siren alarm for [durationSeconds] seconds (default 5).
  /// The siren alternates between two frequencies to create a classic
  /// emergency alert tone.
  Future<void> playAlarm({int durationSeconds = 5}) async {
    // Stop any existing alarm first
    await stopAlarm();

    try {
      _player = AudioPlayer();
      final wavBytes = _generateSirenWav(durationSeconds: durationSeconds);
      
      await _player!.setSource(BytesSource(wavBytes));
      await _player!.resume();
      _isPlaying = true;

      // Auto-stop after duration
      _stopTimer = Timer(Duration(seconds: durationSeconds), () {
        stopAlarm();
      });
    } catch (e) {
      _isPlaying = false;
      // Silently handle — platform may not support audio
    }
  }

  /// Stops the currently playing alarm.
  Future<void> stopAlarm() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    _isPlaying = false;

    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }

  /// Generates a WAV file as bytes containing a pulsing two-tone siren.
  /// Alternates between 880 Hz and 660 Hz every 0.5 seconds to create
  /// a classic emergency alert pattern.
  Uint8List _generateSirenWav({required int durationSeconds}) {
    const sampleRate = 22050;
    const bitsPerSample = 16;
    const numChannels = 1;
    const bytesPerSample = bitsPerSample ~/ 8;

    final totalSamples = sampleRate * durationSeconds;
    final dataSize = totalSamples * bytesPerSample * numChannels;

    // WAV header (44 bytes) + PCM data
    final buffer = ByteData(44 + dataSize);

    // RIFF header
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, 36 + dataSize, Endian.little); // File size - 8
    buffer.setUint8(8, 0x57);  // W
    buffer.setUint8(9, 0x41);  // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // fmt chunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6D); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // (space)
    buffer.setUint32(16, 16, Endian.little); // Chunk size
    buffer.setUint16(20, 1, Endian.little);  // PCM format
    buffer.setUint16(22, numChannels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * numChannels * bytesPerSample, Endian.little);
    buffer.setUint16(32, numChannels * bytesPerSample, Endian.little);
    buffer.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, dataSize, Endian.little);

    // Generate two-tone siren waveform
    const freq1 = 880.0;  // High tone (A5)
    const freq2 = 660.0;  // Low tone (E5)
    const switchInterval = 0.5; // Switch frequency every 0.5 seconds
    const amplitude = 0.7;

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final cyclePos = (t % (switchInterval * 2));
      final freq = cyclePos < switchInterval ? freq1 : freq2;

      // Add slight frequency sweep within each half-cycle for urgency feel
      final sweepT = (cyclePos % switchInterval) / switchInterval;
      final actualFreq = freq + (freq == freq1 ? -40.0 * sweepT : 40.0 * sweepT);

      // Generate sine wave with envelope
      final envelope = _sirenEnvelope(t, durationSeconds.toDouble());
      final sample = (amplitude * envelope * math.sin(2.0 * math.pi * actualFreq * t));

      // Convert to 16-bit PCM
      final pcmValue = (sample * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(44 + i * bytesPerSample, pcmValue, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  /// Creates pulsing envelope that ramps up, sustains, and fades
  double _sirenEnvelope(double t, double totalDuration) {
    // Quick attack (first 0.1s)
    if (t < 0.1) return t / 0.1;
    // Quick fade out (last 0.3s)
    if (t > totalDuration - 0.3) return (totalDuration - t) / 0.3;
    // Pulsing sustain with slight modulation for urgency
    return 0.85 + 0.15 * math.sin(2.0 * math.pi * 4.0 * t);
  }
}
