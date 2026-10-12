import 'package:flutter/material.dart';
import 'package:prj2/views/onboarding_items.dart';
import 'package:prj2/views/onboarding_page.dart';

class OnBoardingViewBody extends StatefulWidget {
  const OnBoardingViewBody({super.key});

  @override
  State<OnBoardingViewBody> createState() => _OnBoardingViewBodyState();
}

class _OnBoardingViewBodyState extends State<OnBoardingViewBody> {
  late final PageController _pageController;

  int currentIndex = 0;

  final List<Color> colors = const [
    Color(0xFFFFFFFF),
    Color(0xFF98DFD5),
    Color(0xFFFFADC4),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  void nextPage() {
    if (!_pageController.hasClients) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void skipPages() {
    if (!_pageController.hasClients) return;

    final nextIndex = currentIndex + 1;
    final targetIndex =
        nextIndex +
        (onBoardingItems.length - nextIndex % onBoardingItems.length) %
            onBoardingItems.length;

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (onBoardingItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return PageView.builder(
      controller: _pageController,

      itemCount: null,

      onPageChanged: (index) {
        setState(() {
          currentIndex = index % onBoardingItems.length;
        });
      },

      itemBuilder: (context, index) {
        final itemIndex = index % onBoardingItems.length;
        final colorIndex = index % colors.length;
        final nextColorIndex = (colorIndex + 1) % colors.length;

        return OnboardingPage(
          key: ValueKey(index),
          item: onBoardingItems[itemIndex],
          index: itemIndex,
          backgroundColor: colors[colorIndex],
          nextColor: colors[nextColorIndex],
          onSkip: skipPages,
          onNext: nextPage,
        );
      },
    );
  }
}
