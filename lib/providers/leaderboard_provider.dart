import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment_models.dart';
import '../repositories/assessment_repository.dart';
import 'assessment_provider.dart';

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? collegeFilter;

  LeaderboardState({
    this.entries = const [],
    this.isLoading = false,
    this.collegeFilter,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    String? collegeFilter,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      collegeFilter: collegeFilter ?? this.collegeFilter,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final AssessmentRepository _repository;

  LeaderboardNotifier(this._repository) : super(LeaderboardState()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard({String? collegeFilter}) async {
    state = state.copyWith(isLoading: true, collegeFilter: collegeFilter);
    try {
      final list = await _repository.getLeaderboard(collegeFilter: collegeFilter);
      state = state.copyWith(entries: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final repo = ref.watch(assessmentRepositoryProvider);
  return LeaderboardNotifier(repo);
});
