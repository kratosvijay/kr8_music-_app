import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioSynthService {
  static final AudioSynthService _instance = AudioSynthService._internal();
  factory AudioSynthService() => _instance;
  AudioSynthService._internal() {
    _initAudioSession();
  }

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
      ));
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }
  }

  void dispose() {
    _player.dispose();
    _errorPlayer.dispose();
  }

  // Frequencies for our 12 nodes mapped chroamtically (C4 to B4 and C5 for octave resolution)
  static const Map<String, double> noteFrequencies = {
    'C4': 261.63,   // Tonic T1
    'C#4': 277.18,  // O1
    'D4': 293.66,   // O2
    'D#4': 311.13,  // O3
    'E4': 329.63,   // O4
    'F4': 349.23,   // T2
    'F#4': 369.99,  // D1
    'G4': 392.00,   // T3
    'G#4': 415.30,  // O5
    'A4': 440.00,   // O6
    'A#4': 466.16,  // O7
    'B4': 493.88,   // O8
    'C5': 523.25,   // C5 Octave resolution
  };

  static const double errorFrequency = 130.81; // Low C3 for buzzer

  Uint8List generateWavBytes(double frequency, double durationSeconds, {bool isError = false}) {
    const int sampleRate = 44100;
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final int numChannels = 1;
    final int bitsPerSample = 16;
    final int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int dataSize = numSamples * blockAlign;
    final int fileSize = 44 + dataSize;

    final ByteData header = ByteData(44);
    
    // RIFF
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize - 8, Endian.little);
    
    // WAVE
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    
    // fmt
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    
    // data
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    final Uint8List wavBytes = Uint8List(fileSize);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());

    final ByteData dataView = ByteData.view(wavBytes.buffer, 44, dataSize);

    final int fadeInSamples = (sampleRate * 0.015).toInt(); // 15ms fade in
    final int fadeOutSamples = (sampleRate * 0.08).toInt();  // 88ms fade out

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sampleValue = 0.0;

      if (isError) {
        // Sawtooth wave mixed with second harmonic for a buzzy, warning tone
        double sawVal = 2.0 * (t * frequency - (t * frequency + 0.5).floor());
        double sawHarmonic = 2.0 * (t * frequency * 2 - (t * frequency * 2 + 0.5).floor());
        sampleValue = 0.6 * sawVal + 0.4 * sawHarmonic;
      } else {
        // Pure sine wave for beautiful musical notes
        sampleValue = sin(2 * pi * frequency * t);
      }

      double envelope = 1.0;
      if (i < fadeInSamples) {
        envelope = i / fadeInSamples;
      } else if (i > numSamples - fadeOutSamples) {
        envelope = (numSamples - i) / fadeOutSamples;
      }

      int intVal = (sampleValue * 26000 * envelope).round().clamp(-32768, 32767);
      dataView.setInt16(i * 2, intVal, Endian.little);
    }

    return wavBytes;
  }

  Future<void> playFrequency(double frequency, {double duration = 0.8, bool isError = false}) async {
    try {
      final bytes = generateWavBytes(frequency, duration, isError: isError);
      final source = BytesAudioSource(bytes, mimeType: 'audio/wav');
      final player = isError ? _errorPlayer : _player;
      
      // Stop current playback if active
      if (player.playing) {
        await player.stop();
      }
      
      await player.setAudioSource(source);
      await player.play();
    } catch (e) {
      debugPrint('Error playing frequency: $e');
    }
  }

  Future<void> playNote(String noteName, {double duration = 0.8}) async {
    final freq = noteFrequencies[noteName];
    if (freq != null) {
      await playFrequency(freq, duration: duration);
    }
  }

  Future<void> playWarning() async {
    await playFrequency(errorFrequency, duration: 0.4, isError: true);
  }
}

class BytesAudioSource extends StreamAudioSource {
  final Uint8List bytes;
  final String mimeType;

  BytesAudioSource(this.bytes, {required this.mimeType});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final int actualStart = start ?? 0;
    final int actualEnd = end ?? bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: actualEnd - actualStart,
      offset: actualStart,
      stream: Stream.value(bytes.sublist(actualStart, actualEnd)),
      contentType: mimeType,
    );
  }
}
