import 'package:khuta/models/child.dart';

/// Abstract repository interface for child data operations.
/// Implementations can use Firebase, local storage, or mock data.
abstract class ChildRepository {
  /// Get all children for the current user (excluding soft-deleted)
  Future<List<Child>> getChildren();

  /// Get a single child by ID
  Future<Child?> getChild(String childId);

  /// Add a new child
  Future<String> addChild(Child child);

  /// Update a child
  Future<void> updateChild(Child child);

  /// Soft delete a child (sets isDeleted = true)
  Future<void> deleteChild(String childId);

  /// Stream of children for real-time updates
  Stream<List<Child>> watchChildren();
}
