import 'package:flutter/material.dart';
import '../consts/app_themes.dart';

class TgMark extends StatelessWidget {
  final double size;
  const TgMark({super.key, this.size = 110});
  @override
  Widget build(BuildContext context) => Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * .28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBCA8FF), AppThemes.purple, Color(0xFF4D2CB4)],
      ),
      boxShadow: [
        BoxShadow(
          color: AppThemes.purple.withValues(alpha: .27),
          blurRadius: 34,
          offset: const Offset(0, 17),
        ),
      ],
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: size * .12,
          left: size * .16,
          child: Container(
            width: size * .46,
            height: size * .11,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Text(
          'TG',
          style: TextStyle(
            fontSize: size * .35,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 58,
    width: double.infinity,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppThemes.purple, Color(0xFF9D70F4)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppThemes.purple.withValues(alpha: .22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    ),
  );
}

class FloatingArt extends StatefulWidget {
  final IconData icon;
  final Color color;
  const FloatingArt({super.key, required this.icon, required this.color});
  @override
  State<FloatingArt> createState() => _FloatingArtState();
}

class _FloatingArtState extends State<FloatingArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) => Transform.translate(
      offset: Offset(0, -7 + 14 * _animation.value),
      child: child,
    ),
    child: SizedBox(
      width: 254,
      height: 252,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withValues(alpha: .22),
                  widget.color.withValues(alpha: .02),
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: -.14,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withValues(alpha: .73),
                    widget.color,
                    const Color(0xFF4D2CB4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: .35),
                    blurRadius: 35,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Icon(widget.icon, size: 82, color: Colors.white),
            ),
          ),
          Positioned(
            top: 17,
            right: 12,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 31,
              color: widget.color.withValues(alpha: .75),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 20,
            child: Icon(
              Icons.circle,
              size: 20,
              color: widget.color.withValues(alpha: .32),
            ),
          ),
        ],
      ),
    ),
  );
}
