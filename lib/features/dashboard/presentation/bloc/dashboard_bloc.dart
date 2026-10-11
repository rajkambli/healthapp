import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardState()) {
    on<DashboardStarted>(
      _onStarted,
      transformer: droppable(),
    );
    on<DashboardRefreshed>(
      _onRefreshed,
      transformer: droppable(),
    );
    on<DashboardRetried>(
      _onRetried,
      transformer: droppable(),
    );
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    // 1. Check local cache first and emit immediately if present
    final cached = await _repository.getCachedDailyMetrics();
    if (cached != null) {
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          calories: cached.calories,
          lastUpdated: cached.lastUpdated,
          isOffline: true,
          clearError: true,
        ),
      );
    } else {
      emit(state.copyWith(status: DashboardStatus.loading, clearError: true));
    }

    // 2. Fetch fresh data from remote
    await _fetchData(emit);
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    // Pull-to-refresh: keep current data visible while fetching
    await _fetchData(emit);
  }

  Future<void> _onRetried(
    DashboardRetried event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<DashboardState> emit) async {
    try {
      final metrics = await _repository.fetchDailyMetrics(forceRefresh: true);
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          calories: metrics.calories,
          lastUpdated: metrics.lastUpdated,
          isOffline: metrics.isFromCache,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      _handleError(e.message, emit);
    } catch (e) {
      _handleError('Unable to fetch latest metrics: $e', emit);
    }
  }

  void _handleError(String message, Emitter<DashboardState> emit) {
    if (state.calories != null) {
      // If we have cached data, retain it and indicate offline mode
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          isOffline: true,
          errorMessage: message,
        ),
      );
    } else {
      // No cached data available: show full-screen error
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }
}
