class HomeState {
  final int selectedIndex;
  final bool isCommunityUpdateVisible;

  HomeState({
    required this.selectedIndex,
    required this.isCommunityUpdateVisible,
  });

  HomeState copyWith({
    int? selectedIndex,
    bool? isCommunityUpdateVisible,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCommunityUpdateVisible: isCommunityUpdateVisible ?? this.isCommunityUpdateVisible,
    );
  }
}
