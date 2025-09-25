import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workflow_task.dart';

class WorkflowTaskService {
  WorkflowTaskService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('workflowTasks');

  Stream<List<WorkflowTask>> watchTasks() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WorkflowTask.fromSnapshot)
              .toList(growable: false),
        );
  }

  Future<void> createTask({
    required String orderNumber,
    required String owner,
    required String status,
  }) async {
    await _collection.add(<String, dynamic>{
      'orderNumber': orderNumber,
      'owner': owner,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String id) {
    return _collection.doc(id).delete();
  }
}
