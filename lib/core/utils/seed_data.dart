import '../constants/app_constants.dart';
import '../../features/explore/models/kink_model.dart';
import '../../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeeder {
  static final DatabaseService _db = DatabaseService();

  static Future<void> seedKinks() async {
    final kinks = [
      KinkModel(
        id: 'bdsm',
        title: 'BDSM',
        description: 'Umbrella term for bondage, discipline, domination, submission, sadism, and masochism. Erotic exchange of power.',
        category: 'Power Play',
        likes: 67,
        iconName: 'security',
        colorHex: '9B30FF',
      ),
      KinkModel(
        id: 'sadism_masochism',
        title: 'Sadism & Masochism',
        description: 'Pleasure from inflicting or receiving pain in a consensual context.',
        category: 'Sensory',
        likes: 45,
        iconName: 'flash_on',
        colorHex: 'FF3030',
      ),
      KinkModel(
        id: 'ropes_bondage',
        title: 'Ropes & Bondage',
        description: 'Restricting a partner or being restricted using ropes or other restraints.',
        category: 'BDSM',
        likes: 89,
        iconName: 'link',
        colorHex: '8B4513',
      ),
      KinkModel(
        id: 'hosiery',
        title: 'Hosiery',
        description: 'Interest in wearing or seeing a partner wear pantyhose or stockings.',
        category: 'Clothing',
        likes: 34,
        iconName: 'accessibility',
        colorHex: 'FF69B4',
      ),
      KinkModel(
        id: 'voyeurism',
        title: 'Voyeurism',
        description: 'Arousal from watching others engage in sexual activity or seeing oneself in a mirror.',
        category: 'Sensory',
        likes: 56,
        iconName: 'visibility',
        colorHex: '4169E1',
      ),
      KinkModel(
        id: 'exhibitionism',
        title: 'Exhibitionism',
        description: 'Arousal from being observed by others while naked or engaging in sexual acts.',
        category: 'Sensory',
        likes: 62,
        iconName: 'camera_alt',
        colorHex: 'FF8C00',
      ),
      KinkModel(
        id: 'roleplay',
        title: 'Roleplay',
        description: 'Taking on different personas or characters to intensify sexual pleasure.',
        category: 'Roleplay',
        likes: 120,
        iconName: 'masks',
        colorHex: '9370DB',
      ),
      KinkModel(
        id: 'dirty_talk',
        title: 'Dirty Talk',
        description: 'Using explicit or suggestive language to heighten sensation and excitement.',
        category: 'Communication',
        likes: 95,
        iconName: 'record_voice_over',
        colorHex: 'CD5C5C',
      ),
      KinkModel(
        id: 'urophilia',
        title: 'Urophilia (Piss Play)',
        description: 'Sexual arousal from urination, either giving or receiving (golden showers).',
        category: 'Fluid Play',
        likes: 22,
        iconName: 'water_drop',
        colorHex: 'FFD700',
      ),
      KinkModel(
        id: 'nipple_play',
        title: 'Nipple Play',
        description: 'Intense focus on nipple stimulation for pleasure or dominance.',
        category: 'Sensory',
        likes: 88,
        iconName: 'adjust',
        colorHex: 'E9967A',
      ),
      KinkModel(
        id: 'humiliation',
        title: 'Humiliation',
        description: 'Being "put in one\'s place" or degraded by a partner in a consensual power dynamic.',
        category: 'Power Play',
        likes: 41,
        iconName: 'arrow_downward',
        colorHex: '4B0082',
      ),
      KinkModel(
        id: 'cuckolding',
        title: 'Cuckolding',
        description: 'Arousal from watching or knowing your partner has sex with someone else.',
        category: 'Roleplay',
        likes: 37,
        iconName: 'group',
        colorHex: '2F4F4F',
      ),
      KinkModel(
        id: 'flr',
        title: 'Female-Led Relationship',
        description: 'Dynamics where the woman holds the bulk of the sexual and relationship control.',
        category: 'Power Play',
        likes: 54,
        iconName: 'woman',
        colorHex: 'C71585',
      ),
      KinkModel(
        id: 'findom',
        title: 'Financial Domination',
        description: 'Giving control of finances or purchasing power to a dominant partner.',
        category: 'Power Play',
        likes: 19,
        iconName: 'account_balance_wallet',
        colorHex: '228B22',
      ),
      KinkModel(
        id: 'auralism',
        title: 'Auralism (Sound Kink)',
        description: 'Arousal from specific sounds, moans, or audio erotica/ASMR.',
        category: 'Sensory',
        likes: 67,
        iconName: 'hearing',
        colorHex: 'FF7F50',
      ),
      KinkModel(
        id: 'age_play',
        title: 'Age Play',
        description: 'Consensual roleplay where adults take on roles of different ages (e.g., Little/Daddy).',
        category: 'Roleplay',
        likes: 52,
        iconName: 'child_care',
        colorHex: '87CEEB',
      ),
      KinkModel(
        id: 'orgasm_control',
        title: 'Orgasm Control',
        description: 'Letting a partner decide the timing and outcome of one\'s climax.',
        category: 'Power Play',
        likes: 110,
        iconName: 'timer',
        colorHex: 'DC143C',
      ),
      KinkModel(
        id: 'impact_play',
        title: 'Impact Play',
        description: 'Activities like spanking, paddling, or caning to release endorphins.',
        category: 'Sensory',
        likes: 85,
        iconName: 'back_hand',
        colorHex: 'A52A2A',
      ),
      KinkModel(
        id: 'cnc',
        title: 'Consensual Non-Consent',
        description: 'Engaging in "taken" fantasies where participants pretend to resist in a pre-agreed scene.',
        category: 'Power Play',
        likes: 48,
        iconName: 'gavel',
        colorHex: '000000',
      ),
      KinkModel(
        id: 'gags',
        title: 'Gags',
        description: 'Arousal from being unable to speak or having one\'s mouth obstructed.',
        category: 'BDSM',
        likes: 63,
        iconName: 'speaker_notes_off',
        colorHex: '696969',
      ),
      KinkModel(
        id: 'praise_kink',
        title: 'Praise Kink',
        description: 'Arousal from receiving compliments and encouragement in a sexual context.',
        category: 'Communication',
        likes: 145,
        iconName: 'thumb_up',
        colorHex: 'DAA520',
      ),
      KinkModel(
        id: 'degradation_kink',
        title: 'Degradation',
        description: 'Arousal from being denigrated or treated as "lesser" by a partner.',
        category: 'Power Play',
        likes: 59,
        iconName: 'thumb_down',
        colorHex: '363636',
      ),
      KinkModel(
        id: 'blood_play',
        title: 'Blood Play',
        description: 'Arousal from the sight or drawing of blood. Requires extreme safety and sterilization.',
        category: 'Sensory',
        likes: 15,
        iconName: 'bloodtype',
        colorHex: '990000',
      ),
      KinkModel(
        id: 'furries',
        title: 'Furries (Plushophilia)',
        description: 'Dressing as or imagining oneself as an anthropomorphic animal.',
        category: 'Roleplay',
        likes: 42,
        iconName: 'pets',
        colorHex: 'DEB887',
      ),
      KinkModel(
        id: 'mummification',
        title: 'Mummification',
        description: 'Being tightly wrapped (e.g., in plastic wrap or bandages) for intense restraint.',
        category: 'BDSM',
        likes: 28,
        iconName: 'layers',
        colorHex: 'F5DEB3',
      ),
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var kink in kinks) {
      final ref = FirebaseFirestore.instance.collection(AppConstants.kinksCollection).doc(kink.id);
      batch.set(ref, kink.toMap());
    }
    
    // Also seed categories
    final categories = kinks.map((k) => k.category).toSet().toList();
    final metaRef = FirebaseFirestore.instance.collection('metadata').doc('kink_categories');
    batch.set(metaRef, {'categories': categories}, SetOptions(merge: true));

    await batch.commit();
  }
}
