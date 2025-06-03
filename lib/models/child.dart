import 'package:equatable/equatable.dart';

class Child extends Equatable {
  final String id;
  final String name;
  final int age;
  final String gender;
  final int? score;
  final String? lastEvaluationType;
  final DateTime? lastEvaluationDate;

  const Child({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.score,
    this.lastEvaluationType,
    this.lastEvaluationDate,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    gender,
    score,
    lastEvaluationType,
    lastEvaluationDate,
  ];

  Child copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    int? score,
    String? lastEvaluationType,
    DateTime? lastEvaluationDate,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      score: score ?? this.score,
      lastEvaluationType: lastEvaluationType ?? this.lastEvaluationType,
      lastEvaluationDate: lastEvaluationDate ?? this.lastEvaluationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'score': score,
      'lastEvaluationType': lastEvaluationType,
      'lastEvaluationDate': lastEvaluationDate?.toIso8601String(),
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      score: json['score'] as int?,
      lastEvaluationType: json['lastEvaluationType'] as String?,
      lastEvaluationDate: json['lastEvaluationDate'] != null
          ? DateTime.parse(json['lastEvaluationDate'] as String)
          : null,
    );
  }
}
