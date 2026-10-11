import 'package:equatable/equatable.dart';
import '../../domain/entities/calories_data.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final CaloriesData? calories;
  final bool isOffline;
  final DateTime? lastUpdated;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.calories,
    this.isOffline = false,
    this.lastUpdated,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    CaloriesData? calories,
    bool? isOffline,
    DateTime? lastUpdated,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      calories: calories ?? this.calories,
      isOffline: isOffline ?? this.isOffline,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        calories,
        isOffline,
        lastUpdated,
        errorMessage,
      ];
}
