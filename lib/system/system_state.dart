import 'dart:ui';
import '../Service/system_modal.dart';

class SystemState {
  final List<SystemModal> systems;
  final List<SystemModal> displayedSystems;
  final List<SystemModal> requests;
  final Map<String, Color> statusColors;
  final String searchQuery;
  final String statusFilter;

  const SystemState({
    this.systems = const [],
    this.displayedSystems = const [],
    this.requests = const [],
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.statusColors = const {},
  });

  SystemState copyWith({
    List<SystemModal>? systems,
    List<SystemModal>? displayedSystems,
    List<SystemModal>? requests,
    String? searchQuery,
    String? statusFilter,
    Map<String, Color>? statusColors,
    Map<String, Color>? statusTextColors,
  }) {
    return SystemState(
      systems: systems ?? this.systems,
      displayedSystems: displayedSystems ?? this.displayedSystems,
      requests: requests ?? this.requests,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      statusColors: statusColors ?? this.statusColors,
    );
  }
}
