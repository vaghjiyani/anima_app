import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class StarRatingWidget extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40.0,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int? _hoverRating;
  final List<int> _bouncingStars = [];

  Future<void> _triggerHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }
  }

  void _updateRating(int rating) {
    if (rating != widget.rating) {
      _triggerHaptic();
      widget.onRatingChanged(rating);

      // Trigger bounce animation
      setState(() {
        _bouncingStars.add(rating);
      });

      // Remove bounce after animation completes
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _bouncingStars.remove(rating);
          });
        }
      });
    }
  }

  void _handleDragUpdate(
    DragUpdateDetails details,
    BoxConstraints constraints,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final starWidth = constraints.maxWidth / 5;
    final rating = ((localPosition.dx / starWidth).ceil()).clamp(1, 5);

    if (rating != _hoverRating) {
      setState(() {
        _hoverRating = rating;
      });
      _updateRating(rating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, constraints),
          onHorizontalDragEnd: (_) {
            setState(() {
              _hoverRating = null;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isActive = starNumber <= widget.rating;
              final isBouncing = _bouncingStars.contains(starNumber);

              return Semantics(
                label: 'Star $starNumber',
                button: true,
                child: GestureDetector(
                  onTap: () => _updateRating(starNumber),
                  child: AnimatedScale(
                    scale: isBouncing ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          isActive ? Icons.star : Icons.star_border,
                          size: widget.size,
                          color: isActive
                              ? widget.activeColor
                              : widget.inactiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
