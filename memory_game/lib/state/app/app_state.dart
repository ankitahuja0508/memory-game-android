import 'package:equatable/equatable.dart';

/// App-wide state
enum AppStatus {
  initial,
  loading,
  ready,
  error,
}

class AppState extends Equatable {
  final AppStatus status;
  final bool isFirstLaunch;
  final String? error;

  const AppState({
    this.status = AppStatus.initial,
    this.isFirstLaunch = true,
    this.error,
  });

  AppState copyWith({
    AppStatus? status,
    bool? isFirstLaunch,
    String? error,
    bool clearError = false,
  }) {
    return AppState(
      status: status ?? this.status,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, isFirstLaunch, error];
}
