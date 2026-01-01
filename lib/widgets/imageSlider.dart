import 'dart:async';
import 'package:ajarly/const/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AutoImageSlider extends StatefulWidget {
  const AutoImageSlider({super.key});

  @override
  State<AutoImageSlider> createState() => _AutoImageSliderState();
}

class _AutoImageSliderState extends State<AutoImageSlider> {
  final _controller = PageController();
  final _images = ['assets/1.jpg', 'assets/2.jpg', 'assets/1.jpg'];

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (_controller.page!.round() + 1) % _images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(),
          height: AppDimensions.screenHeight * .25,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _controller,
              itemCount: _images.length,
              itemBuilder: (_, i) => Image.asset(_images[i], fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        SmoothPageIndicator(
          controller: _controller,
          count: _images.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: primary,
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}
