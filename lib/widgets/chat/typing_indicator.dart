// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

class DotWidget extends StatelessWidget {
  final Color? color;
  final double? radius;

  const DotWidget({
    Key? key,
    @required this.color,
    @required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      height: radius,
      width: radius,
    );
  }
}

/// Jumping Dot.
///
/// [numberOfDots] number of dots,
/// [color] color of dots.
/// [radius] radius of dots.
/// [animationDuration] animation duration in milliseconds
class JumpingDots extends StatefulWidget {
  final int numberOfDots;
  final Color color;
  final double radius;
  final double innerPadding;
  final Duration animationDuration;

  /// Defines how much the animation will offset negatively in the `y` axis.
  /// Can be either positive or negative, as it'll later be converted into its
  /// negative value.
  ///
  /// Non-finite or zero (0) values are not accepted.
  final double verticalOffset;

  JumpingDots({
    Key? key,
    this.numberOfDots = 3,
    this.radius = 8,
    this.innerPadding = 2,
    this.animationDuration = const Duration(milliseconds: 200),
    this.color = APP_ACCENT_COLOR,
    this.verticalOffset = -5,
  })  : assert(verticalOffset.isFinite,
            "Non-finite values cannot be set as an animation offset."),
        assert(verticalOffset != 0,
            "Zero values (0) cannot be set as an animation offset."),
        super(key: key);

  @override
  State<JumpingDots> createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<JumpingDots>
    with TickerProviderStateMixin {
  List<AnimationController>? _animationControllers;

  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers!) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initAnimation() {
    if (!mounted) {
      return;
    }
    _animationControllers = List.generate(
      widget.numberOfDots,
      (index) {
        return AnimationController(
            vsync: this, duration: widget.animationDuration);
      },
    ).toList();

    for (int i = 0; i < widget.numberOfDots; i++) {
      _animations.add(Tween<double>(
              begin: 0,
              end:
                  -widget.verticalOffset.abs() // Ensure the offset is negative.
              )
          .animate(_animationControllers![i]));
    }

    for (int i = 0; i < widget.numberOfDots; i++) {
      _animationControllers![i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationControllers![i].reverse();
          if (i != widget.numberOfDots - 1) {
            _animationControllers![i + 1].forward();
          }
        }
        if (i == widget.numberOfDots - 1 &&
            status == AnimationStatus.dismissed) {
          _animationControllers![0].forward();
        }
      });
    }
    _animationControllers!.first.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(widget.numberOfDots, (index) {
      return AnimatedBuilder(
        animation: _animationControllers![index],
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(widget.innerPadding),
            child: Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: DotWidget(color: widget.color, radius: widget.radius),
            ),
          );
        },
      );
    }).toList());
  }
}
