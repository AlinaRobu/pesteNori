import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/map/models/HikingRoute.dart';

class HikeRecord {
  HikeRecord(this.id, Map<String, dynamic> data)
    : trailName = data['trailName'] as String,
      startedAt = (data['startedAt'] as Timestamp).toDate(),
      endedAt = (data['endedAt'] as Timestamp?)?.toDate(),
      weather = data['weather'] as String?,
      temperatureC = (data['temperatureC'] as num?)?.toDouble();

  final String id;
  final String trailName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? weather;
  final double? temperatureC;
}

class HikeHistoryService {
  final _routes = FirebaseFirestore.instance.collection('routes');

  DocumentReference<Map<String, dynamic>> newHike() => _routes.doc();

  Future<void> start(
    DocumentReference<Map<String, dynamic>> record,
    HikingRoute trail,
    DateTime startedAt,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in to record hikes.');
    await record.set({
      'ownerId': user.uid,
      'trailId': trail.id,
      'trailName': trail.name,
      'startedAt': Timestamp.fromDate(startedAt),
    });
  }

  Future<void> finish(
    DocumentReference<Map<String, dynamic>> record,
    DateTime endedAt,
  ) => record.update({'endedAt': Timestamp.fromDate(endedAt)});

  Stream<List<HikeRecord>> watchHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _routes.where('ownerId', isEqualTo: user.uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => HikeRecord(doc.id, doc.data())).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    });
  }

  Future<void> saveWeather(String id, String? weather, double? temperatureC) =>
      _routes.doc(id).update({
        'weather': weather,
        'temperatureC': temperatureC,
      });
}
