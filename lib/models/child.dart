import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khuta/models/test_result.dart';

class Child {
  final String id;
  final String name;
  final String gender; // 'male' or 'female'
  final int age;
  final List<TestResult> testResults;
  final DateTime createdAt;

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.testResults,
    required this.createdAt,
  });

  factory Child.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Child(
      id: doc.id,
      name: data['name'] ?? '',
      gender: data['gender'] ?? 'male',
      age: data['age'] ?? 0,
      testResults:
          (data['testResults'] as List<dynamic>?)
              ?.map((e) => TestResult.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'testResults': testResults.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
