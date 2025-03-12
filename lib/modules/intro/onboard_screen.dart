import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/routes/navigator_helper.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/image/image_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      StorageService.firstInstall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                OnboardPage(
                  image:
                      'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                  title: 'Welcome',
                  content: 'This is the first page of the onboarding screen.',
                ),
                OnboardPage(
                  image:
                      'https://images.pexels.com/photos/1592384/pexels-photo-1592384.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                  title: 'Discover',
                  content: 'This is the second page of the onboarding screen.',
                ),
                OnboardPage(
                  image:
                      'https://images.pexels.com/photos/13861/IMG_3496bfree.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                  title: 'Get Started',
                  content: 'This is the third page of the onboarding screen.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(
                  onPressed: () {},
                  text: "Back",
                  type: ButtonType.text,
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: WormEffect(
                    dotHeight: 12,
                    dotWidth: 12,
                    activeDotColor: context.colors.primary,
                  ),
                ),
                ButtonWidget(
                  onPressed: () => NavigatorHelper.toAuth(),
                  text: "Skip",
                  type: ButtonType.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String content;

  const OnboardPage({
    super.key,
    required this.image,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageWidget(
          image,
          width: 100.wp,
          height: 60.hp,
          radius: 0,
          borderRadius: const BorderRadius.all(Radius.circular(0)),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: context.headline.copyWith(
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          content,
          textAlign: TextAlign.center,
          // style: context.,
        ),
      ],
    );
  }
}
