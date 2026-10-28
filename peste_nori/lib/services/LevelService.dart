import 'package:cloud_firestore/cloud_firestore.dart';

class LevelService {
  final FirebaseFirestore _auth = FirebaseFirestore.instance;
  static const int MAX_LEVEL = 11;
  final imageUrls = {
    1: "novice.png", 
    2: "explorer.png",
    3: "pathfinder.png",
    4: "wanderer.png",
    5: "ridgewalker.png",
    6: "summitHunter.png",
    7: "mountaineer.png",
    8: "peakConqueror.png",
    9: "mountainGuardian.png",
    10: "carpathianLegend.png",
    11: "grandmaster.png"
  };

  Future<Object?> getLevel(int level) async {
    final snapshot = await _auth
        .collection('levels')
        .where('level', isEqualTo: level)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    Map<String, dynamic> levelData = snapshot.docs.first.data();
    levelData["image"] = imageUrls[levelData["level"]];

    if(level < MAX_LEVEL){
      final snapshotNext = await _auth
        .collection('levels')
        .where('level', isEqualTo: level + 1)
        .limit(1)
        .get();

      if (snapshotNext.docs.isEmpty) return null;
      Map<String, dynamic> nextLevel = snapshotNext.docs.first.data();
      nextLevel["image"] = imageUrls[nextLevel["level"]];

      final currentXp = levelData["xp"];
      final nextLevelXp = nextLevel["xp"];

      final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);
      final remaining = 1.0 - progress;

      nextLevel["progress"] =  (progress * 100);
      nextLevel["remainingPercent"] =  (remaining * 100).toInt();

      levelData["nextLevel"] = nextLevel;
    }
    return levelData;
  }

  Future<void> addLevelsToFirestore() async {

    final xpThresholds = [
      0, 700, 3000, 7000, 12000, 18000,
      26000, 36000, 48000, 80000, 100000
    ];

    final levels = [
      (1, 'Novice'),
      (2, 'Explorer'),
      (3, 'Pathfinder'),
      (4, 'Wanderer'),
      (5, 'Ridgewalker'),
      (6, 'Summit Hunter'),
      (7, 'Mountaineer'),
      (8, 'Peak Conqueror'),
      (9, 'Mountain Guardian'),
      (10, 'Carpathian Legend'),
      (11, 'Grandmaster'),
    ];

    final batch = _auth.batch();

     for (int i = 0; i < levels.length; i++) {
      final lvl = levels[i].$1;
      final title = levels[i].$2;

      final docRef = _auth
          .collection('levels')
          .doc(lvl.toString());

      batch.set(docRef, {
        'level': lvl,
        'title': title,
        'xp': xpThresholds[i],
      });
    }

    await batch.commit();

    print('Successfully added 100 levels!');
  }

  ///------------------------------PRIVATE METHODS--------------------------------///
}
