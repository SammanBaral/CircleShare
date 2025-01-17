import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class OnboardingState {
  final int currentPage;
  final bool isLastPage;

  OnboardingState({required this.currentPage, required this.isLastPage});

  OnboardingState copyWith({int? currentPage, bool? isLastPage}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final int totalPages;
  final PageController pageController = PageController();

  OnboardingCubit(this.totalPages)
      : super(OnboardingState(currentPage: 0, isLastPage: false));

  void goToNextPage() {
    if (state.currentPage < totalPages - 1) {
      final nextPage = state.currentPage + 1;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(
        currentPage: nextPage,
        isLastPage: nextPage == totalPages - 1,
      ));
    }
  }

  void skipOnboarding() {
    pageController.animateToPage(
      totalPages - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    emit(state.copyWith(currentPage: totalPages - 1, isLastPage: true));
  }

  void onPageChanged(int index) {
    emit(state.copyWith(
      currentPage: index,
      isLastPage: index == totalPages - 1,
    ));
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
