import 'package:get/get.dart';
import '../../../core/services/audio_synth_service.dart';
import '../../game/controllers/game_controller.dart';

class RagaController extends GetxController {
  // Heximel Codes
  final RxInt mIndex = 0.obs; // Madhyamam: 0 for Suddha, 1 for Prati
  final RxInt pIndex = 2.obs; // Purvanga: 0 to 5
  final RxInt uIndex = 2.obs; // Uttaranga: 0 to 5

  final RxInt ragaNumber = 15.obs; // Default to Mayamalavagowla (Raga 15)

  // Melakarta Raga names (1 to 72)
  static const List<String> ragaNames = [
    'Kanakangi', 'Ratnangi', 'Ganamurthi', 'Vanaspati', 'Manavati', 'Tanarupi',
    'Senavati', 'Hanumatodi', 'Dhenuka', 'Natakapriya', 'Kokilapriya', 'Rupavati',
    'Gayakapriya', 'Vakulabharanam', 'Mayamalavagowla', 'Chakravakam', 'Suryakantam', 'Hatakambari',
    'Jhankaradhwani', 'Natabhairavi', 'Keeravani', 'Kharaharapriya', 'Gourimanohari', 'Varunapriya',
    'Mararanjani', 'Charukesi', 'Sarasangi', 'Harikambhoji', 'Dheerasankarabharanam', 'Naganandini',
    'Yagapriya', 'Ragavardhini', 'Gangeyabhushani', 'Vagadheeswari', 'Shulini', 'Chalanata',
    'Salagam', 'Jalavarali', 'Jhalavarali', 'Navaneetam', 'Pavani', 'Raghupriya',
    'Gavambhodhi', 'Bhavapriya', 'Shubhapantuvarali', 'Shadvidamargini', 'Suvarnangi', 'Divyamani',
    'Dhavalambari', 'Namanarayani', 'Kamavardhini', 'Ramapriya', 'Gamanasrama', 'Vishwambhari',
    'Shyamalangi', 'Shanmukhapriya', 'Simhendramadhyamam', 'Hemavati', 'Dharmavati', 'Neetimathi',
    'Kantamani', 'Rishabhapriya', 'Latangi', 'Vachaspati', 'Mechakalyani', 'Chitrambari',
    'Sucharitra', 'Jyotiswarupini', 'Dhatuvardhini', 'Nasikabhushani', 'Kosalam', 'Rasikapriya'
  ];

  // Purvanga node configurations (P index: Rishabham & Gandharam combinations)
  static const Map<int, List<String>> purvangaNodes = {
    0: ['O1', 'O2'], // R1, G1
    1: ['O1', 'O3'], // R1, G2
    2: ['O1', 'O4'], // R1, G3
    3: ['O2', 'O3'], // R2, G2
    4: ['O2', 'O4'], // R2, G3
    5: ['O3', 'O4'], // R3, G3
  };

  // Uttaranga node configurations (U index: Dhaivatam & Nishadam combinations)
  static const Map<int, List<String>> uttarangaNodes = {
    0: ['O5', 'O6'], // D1, N1
    1: ['O5', 'O7'], // D1, N2
    2: ['O5', 'O8'], // D1, N3
    3: ['O6', 'O7'], // D2, N2
    4: ['O6', 'O8'], // D2, N3
    5: ['O7', 'O8'], // D3, N3
  };

  @override
  void onInit() {
    super.onInit();
    // Synchronize raga computation on changes
    ever(ragaNumber, (_) => updateHeximelFromDecimal());
  }

  // Calculate Raga number from Heximel Code [M][P][U]
  void calculateRagaFromHeximel() {
    final int m = mIndex.value;
    final int p = pIndex.value;
    final int u = uIndex.value;
    ragaNumber.value = (m * 36) + (p * 6) + u + 1;
  }

  // Reverse conversion: Decimal to Heximel
  void updateHeximelFromDecimal() {
    final int r = ragaNumber.value;
    final int m = r <= 36 ? 0 : 1;
    final int x = r - (m * 36) - 1;
    final int p = x ~/ 6;
    final int u = x % 6;

    mIndex.value = m;
    pIndex.value = p;
    uIndex.value = u;
  }

  // Retrieve current active nodes on the canvas representing the Raga
  List<String> getActiveRagaNodes() {
    final List<String> activeList = ['T1']; // Shadjam (Tonic C4)

    // Rishabham & Gandharam
    final pNodes = purvangaNodes[pIndex.value];
    if (pNodes != null) activeList.addAll(pNodes);

    // Madhyamam (M1 or M2)
    if (mIndex.value == 0) {
      activeList.add('T2'); // M1 (F4)
    } else {
      activeList.add('D1'); // M2 (F#4)
    }

    activeList.add('T3'); // Panchamam (Dominant G4)

    // Dhaivatam & Nishadam
    final uNodes = uttarangaNodes[uIndex.value];
    if (uNodes != null) activeList.addAll(uNodes);

    return activeList;
  }

  // Get notes scale mapping to play back the Raga
  List<String> getRagaNotes() {
    final List<String> notes = [];
    final activeNodes = getActiveRagaNodes();

    // Map each node ID to pitch names chroamtically
    for (final node in activeNodes) {
      final note = GameController.nodeToNote[node];
      if (note != null) {
        notes.add(note);
      }
    }
    
    // Sort notes in chromatic pitch order, and resolve octave (C5)
    // We want the scale order: C4 -> C#4/D4/D#4/E4 -> F4/F#4 -> G4 -> G#4/A4/A#4/B4 -> C5
    notes.sort((a, b) {
      final fA = AudioSynthService.noteFrequencies[a] ?? 0.0;
      final fB = AudioSynthService.noteFrequencies[b] ?? 0.0;
      return fA.compareTo(fB);
    });

    notes.add('C5'); // Append octave tonic to resolve scale resolution
    return notes;
  }

  // Get the traditional name of the current Raga
  String getRagaName() {
    final int idx = ragaNumber.value - 1;
    if (idx >= 0 && idx < ragaNames.length) {
      return ragaNames[idx];
    }
    return 'Unknown Raga';
  }
}
