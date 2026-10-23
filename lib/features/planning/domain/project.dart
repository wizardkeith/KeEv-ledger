import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';

final class Project {
  Project({
    required this.id,
    required this.profileId,
    required this.name,
    this.description,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) {
    if (name != name.trim() || name.isEmpty || name.length > 120) {
      throw ArgumentError('Project name must be trimmed and 1–120 characters');
    }
    if (description != null && description!.length > 500) {
      throw ArgumentError('Project description exceeds 500 characters');
    }
    if (!createdAtUtc.isUtc ||
        !updatedAtUtc.isUtc ||
        updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError('Project timestamps must be ordered UTC instants');
    }
  }

  final LocalId id, profileId;
  final String name;
  final String? description;
  final bool isArchived;
  final DateTime createdAtUtc, updatedAtUtc;
}

final class ProjectSummary {
  const ProjectSummary({
    required this.income,
    required this.expense,
    required this.net,
    required this.isComplete,
    required this.missingCurrencies,
  });

  final Money income, expense, net;
  final bool isComplete;
  final Set<String> missingCurrencies;
}

abstract interface class ProjectRepository {
  Future<Result<Project>> create(Project project);
  Future<Result<Project?>> get(LocalId profileId, LocalId projectId);
  Future<Result<List<Project>>> list(
    LocalId profileId, {
    bool includeArchived = false,
  });
  Future<Result<Project>> update(Project project);
  Future<Result<Project>> archive(
    LocalId profileId,
    LocalId projectId,
    DateTime nowUtc,
  );
}
