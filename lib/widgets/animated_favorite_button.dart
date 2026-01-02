import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// A reusable animated favorite button with delightful animations
class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;
  final Color? favoriteColor;
  final Color? notFavoriteColor;
  final bool showParticles;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 24,
    this.favoriteColor,
    this.notFavoriteColor,
    this.showParticles = true,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _particlesController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particlesAnimation;

  final List<_HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Scale animation for the heart
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_scaleController);

    // Pulse/ripple animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // Particles animation
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particlesController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Start scale animation
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // If adding to favorites, show pulse and particles
    if (!widget.isFavorite) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });

      if (widget.showParticles) {
        _generateParticles();
        _particlesController.forward(from: 0.0);
      }
    }

    widget.onToggle();
  }

  void _generateParticles() {
    _particles.clear();
    final random = math.Random();

    for (int i = 0; i < 6; i++) {
      _particles.add(
        _HeartParticle(
          angle: (i * 60.0) + random.nextDouble() * 30 - 15,
          distance: 40 + random.nextDouble() * 20,
          size: 8 + random.nextDouble() * 6,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteColor = widget.favoriteColor ?? Colors.red;
    final notFavoriteColor = widget.notFavoriteColor ?? Colors.white;

    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size * 2.5,
        height: widget.size * 2.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse/ripple effect
            if (!widget.isFavorite)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  if (_pulseController.status == AnimationStatus.forward ||
                      _pulseController.status == AnimationStatus.reverse) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseAnimation.value * 1.5),
                      child: Container(
                        width: widget.size * 1.5,
                        height: widget.size * 1.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: favoriteColor.withOpacity(
                            0.3 * (1 - _pulseAnimation.value),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // Floating particles
            if (widget.showParticles)
              AnimatedBuilder(
                animation: _particlesAnimation,
                builder: (context, child) {
                  if (_particlesController.status == AnimationStatus.forward ||
                      _particlesController.status == AnimationStatus.reverse) {
                    return Stack(
                      alignment: Alignment.center,
                      children: _particles.map((particle) {
                        final progress = _particlesAnimation.value;
                        final angle = particle.angle * math.pi / 180;
                        final distance = particle.distance * progress;

                        return Transform.translate(
                          offset: Offset(
                            math.cos(angle) * distance,
                            math.sin(angle) * distance - (progress * 20),
                          ),
                          child: Opacity(
                            opacity: 1 - progress,
                            child: Icon(
                              Icons.favorite,
                              size: particle.size * (1 - progress * 0.5),
                              color: favoriteColor,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // Main heart icon
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      key: ValueKey(widget.isFavorite),
                      size: widget.size,
                      color: widget.isFavorite
                          ? favoriteColor
                          : notFavoriteColor,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartParticle {
  final double angle;
  final double distance;
  final double size;

  _HeartParticle({
    required this.angle,
    required this.distance,
    required this.size,
  });
}
