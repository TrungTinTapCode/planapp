/// Model cho Project để chuyển đổi giữa Entity và Firestore
/// Vị trí: lib/data/models/project_model.dart

import '../../domain/entities/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Model sang Entity
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      description: description,
      ownerId: ownerId,
      memberIds: memberIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Chuyển từ Entity sang Model
  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      ownerId: entity.ownerId,
      memberIds: entity.memberIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Chuyển từ Map (Firestore) sang Model
  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Chuyển từ Model sang Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}