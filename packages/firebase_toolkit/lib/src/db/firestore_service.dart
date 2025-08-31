import 'package:cloud_firestore/cloud_firestore.dart';

typedef FromMap<T> = T Function(String id, Map<String, dynamic> data);
typedef ToMap<T> = Map<String, dynamic> Function(T value);

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String path) =>
      _db.collection(path);

  Stream<List<T>> watchCollection<T>({
    required String path,
    required FromMap<T> fromMap,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> q)? query,
  }) {
    final q = query?.call(_col(path)) ?? _col(path);
    return q
        .snapshots()
        .map((s) => s.docs.map((d) => fromMap(d.id, d.data())).toList());
  }

  Stream<T?> watchDoc<T>({
    required String docPath,
    required T Function(Map<String, dynamic>? data) fromMap,
  }) =>
      _db.doc(docPath).snapshots().map((d) => fromMap(d.data()));

  Future<String> add<T>(
      {required String path, required T value, required ToMap<T> toMap}) async {
    final ref = await _col(path).add(toMap(value));
    return ref.id;
  }

  Future<void> set<T>(
          {required String docPath,
          required T value,
          required ToMap<T> toMap,
          bool merge = true}) =>
      _db.doc(docPath).set(toMap(value), SetOptions(merge: merge));

  Future<void> update(Map<String, Object?> data, {required String docPath}) =>
      _db.doc(docPath).update(data);

  Future<void> delete(String docPath) => _db.doc(docPath).delete();
}
