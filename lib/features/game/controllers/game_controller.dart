import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/audio_synth_service.dart';

enum GameMode { freePlay, listen, play }

class GameController extends GetxController {
  final AudioSynthService _synth = AudioSynthService();

  // Observable states
  final RxInt currentLevel = 1.obs;
  final Rx<GameMode> gameMode = GameMode.freePlay.obs;
  final RxString highlightedNode = ''.obs;
  final RxList<String> targetSequence = <String>[].obs;
  final RxList<String> userSequence = <String>[].obs;
  
  final RxInt score = 0.obs;
  final RxInt streak = 15.obs; // Starting streak from UI design
  final RxInt currentStage = 0.obs;
  final RxString statusMessage = 'Tap shapes to hear notes, or select a level to begin!'.obs;
  final RxBool hasError = false.obs;

  // Node to Note mappings
  static const Map<String, String> nodeToNote = {
    'T1': 'C4',
    'O1': 'C#4',
    'O2': 'D4',
    'O3': 'D#4',
    'O4': 'E4',
    'T2': 'F4',
    'D1': 'F#4',
    'T3': 'G4',
    'O5': 'G#4',
    'O6': 'A4',
    'O7': 'A#4',
    'O8': 'B4',
  };

  // Predefined level stages
  // Level 1: Colors & Notes
  final List<List<String>> level1Stages = [
    ['C4', 'F4', 'G4', 'C4'], // Tonic stability pillars: T1 -> T2 -> T3 -> T1
    ['C4', 'C#4', 'D4', 'D#4', 'E4'], // Purvanga lower tetrachord climb: T1 -> O1 -> O2 -> O3 -> O4
    ['G4', 'G#4', 'A4', 'A#4', 'B4'], // Uttaranga upper tetrachord climb: T3 -> O5 -> O6 -> O7 -> O8
    ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'], // Major Scale Expansion
    ['C4', 'C#4', 'D4', 'D#4', 'E4', 'F4', 'F#4', 'G4', 'G#4', 'A4', 'A#4', 'B4'], // Complete Octet Triangulus Traversal
  ];

  // Level 2: Western Scales
  final List<List<String>> level2Stages = [
    ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'], // Major (Radial Expansion)
    ['C4', 'D4', 'D#4', 'F4', 'G4', 'G#4', 'A#4'], // Natural Minor (Radial Contraction)
    ['C4', 'D4', 'D#4', 'F4', 'G4', 'G#4', 'B4'], // Harmonic Minor (Contraction + Tension Shift)
  ];

  @override
  void onClose() {
    _synth.dispose();
    super.onClose();
  }

  // Get note name from node ID
  String getNoteForNode(String nodeId) => nodeToNote[nodeId] ?? 'C4';

  // Get node ID from note name
  String getNodeForNote(String noteName) {
    return nodeToNote.entries
        .firstWhere((e) => e.value == noteName, orElse: () => const MapEntry('', ''))
        .key;
  }

  // Play a note programmatically
  Future<void> playNode(String nodeId) async {
    final note = getNoteForNode(nodeId);
    highlightedNode.value = nodeId;
    await _synth.playNote(note);
    
    // Auto clear highlight after play duration
    Timer(const Duration(milliseconds: 400), () {
      if (highlightedNode.value == nodeId) {
        highlightedNode.value = '';
      }
    });

    if (gameMode.value == GameMode.play) {
      handleUserInput(note);
    }
  }

  // Set the current level
  void startLevel(int level) {
    currentLevel.value = level;
    currentStage.value = 0;
    setupStage();
  }

  // Setup current stage sequence based on level
  void setupStage() {
    gameMode.value = GameMode.freePlay;
    userSequence.clear();
    hasError.value = false;

    if (currentLevel.value == 1) {
      if (currentStage.value >= level1Stages.length) {
        currentStage.value = 0; // wrap around
      }
      targetSequence.assignAll(level1Stages[currentStage.value]);
      statusMessage.value = 'Level 1 - Stage ${currentStage.value + 1}: Tap "Listen" to hear the sequence!';
    } else if (currentLevel.value == 2) {
      if (currentStage.value >= level2Stages.length) {
        currentStage.value = 0; // wrap around
      }
      targetSequence.assignAll(level2Stages[currentStage.value]);
      final scaleName = currentStage.value == 0
          ? 'C Major (Radial Expansion)'
          : currentStage.value == 1
              ? 'C Natural Minor (Radial Contraction)'
              : 'C Harmonic Minor';
      statusMessage.value = 'Level 2 - Scale: $scaleName. Click "Listen".';
    } else {
      statusMessage.value = 'Level 3 - Heximel & Raga Explorer. Play in free mode or design ragas!';
      targetSequence.clear();
    }
  }

  // Listen mode playback
  Future<void> startListening() async {
    if (targetSequence.isEmpty) return;

    gameMode.value = GameMode.listen;
    statusMessage.value = 'Listening to the Octet Traversal...';
    hasError.value = false;

    for (int i = 0; i < targetSequence.length; i++) {
      final note = targetSequence[i];
      final node = getNodeForNote(note);
      
      highlightedNode.value = node;
      await _synth.playNote(note, duration: 0.6);
      
      // Delay before next note in sequence
      await Future.delayed(const Duration(milliseconds: 550));
      highlightedNode.value = '';
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Switch to play mode
    gameMode.value = GameMode.play;
    userSequence.clear();
    statusMessage.value = 'Your turn! Play the same sequence.';
  }

  // Validate user input in Play mode
  Future<void> handleUserInput(String note) async {
    userSequence.add(note);
    final int index = userSequence.length - 1;

    // Check if the tapped note matches the sequence
    if (targetSequence[index] != note) {
      // Mistake! Play warning sound, flash error state, and request redo
      hasError.value = true;
      statusMessage.value = 'Incorrect shape! Listen again and redo.';
      await _synth.playWarning();
      
      // Clear user inputs and reset back to listen mode sequence
      userSequence.clear();
      
      // Clear error flag after 1.5 seconds
      Timer(const Duration(milliseconds: 1500), () {
        hasError.value = false;
      });
      return;
    }

    // If correct note and sequence complete
    if (userSequence.length == targetSequence.length) {
      statusMessage.value = 'Brilliant! Perfect traversal.';
      score.value += 100;
      streak.value += 1;
      gameMode.value = GameMode.freePlay;

      // Play success feedback chime
      await Future.delayed(const Duration(milliseconds: 300));
      for (final noteName in ['C4', 'E4', 'G4', 'C5']) {
        _synth.playNote(noteName, duration: 0.3);
        await Future.delayed(const Duration(milliseconds: 80));
      }

      // Proceed to next stage/level after 2s delay
      Timer(const Duration(milliseconds: 1500), () {
        if (currentLevel.value == 1 && currentStage.value < level1Stages.length - 1) {
          currentStage.value++;
          setupStage();
        } else if (currentLevel.value == 2 && currentStage.value < level2Stages.length - 1) {
          currentStage.value++;
          setupStage();
        } else {
          statusMessage.value = 'Level completed! Try another level or explore.';
        }
      });
    }
  }

  // Play a specific raga scale (used in Level 3 Raga Explorer)
  Future<void> playRagaScale(List<String> notes) async {
    gameMode.value = GameMode.listen;
    for (final note in notes) {
      final node = getNodeForNote(note);
      if (node.isNotEmpty) {
        highlightedNode.value = node;
        await _synth.playNote(note, duration: 0.5);
        await Future.delayed(const Duration(milliseconds: 400));
        highlightedNode.value = '';
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    gameMode.value = GameMode.freePlay;
  }
}
