import 'package:khuta/models/test_result.dart';

/// Abstract repository interface for test result data operations.
/// Implementations can use Firebase, local storage, or mock data.
abstract class TestResultRepository {
  /// Get all test results for a child
  Future<List<TestResult>> getTestResults(String childId);

  /// Get a single test result
  Future<TestResult?> getTestResult(String childId, String resultId);

  /// Save a new test result
  Future<String> saveTestResult(String childId, TestResult result);

  /// Stream of test results for real-time updates
  Stream<List<TestResult>> watchTestResults(String childId);
}
