import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedSetting extends StatefulWidget {
  const AnimatedSetting({super.key});

  @override
  _AnimatedSettingState createState() => _AnimatedSettingState();
}

class _AnimatedSettingState extends State<AnimatedSetting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideAnimation = Tween(
      begin: const Offset(-2, 0),
      end: Offset.zero,
    ).animate(_controller);

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _jumpAnimation = Tween<double>(
      begin: 0,
      end: -50,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(children: [
            SlideTransition(
              position: _slideAnimation,
              child: _buildAnimatedContainer(),
            ),
            Opacity(
              opacity: _opacityAnimation.value,
              child: _buildAnimatedContainer(),
            ),
            Transform.translate(
              offset: Offset(0, _jumpAnimation.value),
              child: _buildAnimatedContainer(),
            ),
          ]);
        },
      ),
    ]);
  }

  Widget _buildAnimatedContainer() {
    return Container(
      height: 100.h,
      width: 100.w,
      color: Colors.amber,
      margin: const EdgeInsets.all(5),
    );
  }
}
