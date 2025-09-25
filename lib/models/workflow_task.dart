import 'package:cloud_firestore/cloud_firestore.dart';

class WorkflowTask {
  WorkflowTask({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.owner,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String owner;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderNumber': orderNumber,
      'status': status,
      'owner': owner,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory WorkflowTask.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for order document ${doc.id}');
    }

    final createdAt = data['createdAt'];
    return WorkflowTask(
      id: doc.id,
      orderNumber: data['orderNumber'] as String? ?? 'Sin numero',
      status: data['status'] as String? ?? 'Sin estado',
      owner: data['owner'] as String? ?? 'Sin responsable',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
