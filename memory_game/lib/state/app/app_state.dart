import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  final bool isInitialized;
  final bool isFirstLaunch;

  const AppState({
    this.isInitialized = false,
    this.isFirstLaunch = true,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isFirstLaunch,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }

  @override
  List<Object?> get props => [isInitialized, isFirstLaunch];
}
