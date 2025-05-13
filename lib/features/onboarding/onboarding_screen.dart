import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
// import 'package:taskmenot/features/auth/presentation/screens/login_screen.dart';
import 'package:taskmenot/features/onboarding/widgets/onboarding_page.dart';
import '../../core/widgets/logo.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,  // Adjust as needed
            left: 0,
            right: 0,
            child: const AppLogo(),  // Centered by default
          ),
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _onLastPage = index == 2;
              });
            },
            children: const [
              OnboardingPage(
                image: 'assets/images/Slide1.png',
                title: 'Stay Organized,\nStay Productive',
                description: 'Keep track of your tasks effortlessly with TaskMeNot.',
                backgroundColor: AppColors.background,
              ),
              OnboardingPage(
                image: 'assets/images/Slide2.png',
                title: 'Access Your Tasks Anytime',
                description: 'Your tasks are securely saved in the cloud.',
                backgroundColor: Color(0xFFC4D9FF),
              ),
              OnboardingPage(
                image: 'assets/images/Slide3.png',
                title: 'Set Reminders &\nCollaborate',
                description: 'Never miss a deadline with smart notifications.',
                backgroundColor: Color(0xFFE8F9FF),
              ),
            ],
          ),

          // Dot Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Colors.black,
                ),
              ),
            ),
          ),

          // Proceed Button
          if (_onLastPage)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('showOnboarding', false);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    );
                  },
                  child: Text(
                    'Proceed to Login',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }
}