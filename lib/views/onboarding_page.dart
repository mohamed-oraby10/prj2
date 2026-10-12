import 'package:flutter/material.dart';
import 'package:prj2/views/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.item,
    required this.index,
    required this.backgroundColor,
    required this.nextColor,
    required this.onSkip,
    required this.onNext,
  });

  final OnboardingModel item;
  final int index;
  final Color backgroundColor;
  final Color nextColor;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _isDragging = false;
  bool _isAnimating = false;

  double _dragDistance = 0;
  double _screenWidth = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
      value: 0,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onNext();
      }

      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (_isAnimating) return;

    _isDragging = true;
    _dragDistance = 0;

    _screenWidth = MediaQuery.of(context).size.width;

    // لو بدأ سحب جديد أثناء رجوع اللون، نوقف الرجوع عند موضعه الحالي.
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _isAnimating) return;

    // السحب لليسار يكشف اللون الجديد تدريجيًا.
    _dragDistance += details.delta.dx;

    final progress = (-_dragDistance / _screenWidth).clamp(0.0, 1.0);

    _controller.value = progress;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || _isAnimating) return;

    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;

    // نكمل الانتقال إذا وصل السحب إلى 35% أو كانت السرعة كافية.
    if (_controller.value >= 0.35 || velocity < -700) {
      _completeTransition();
    } else {
      // لو السحب لم يكتمل، يرجع اللون بسلاسة.
      _controller.reverse();
    }
  }

  void _completeTransition() {
    if (_isAnimating) return;

    _isAnimating = true;
    _isDragging = false;

    _controller.animateTo(
      1,
      duration: Duration(
        milliseconds: (750 * (1 - _controller.value)).round().clamp(1, 750),
      ),
      curve: Curves.easeOutCubic,
    );
  }

  void _startButtonTransition() {
    if (_isAnimating) return;

    _isAnimating = true;

    _controller.animateTo(
      1,
      duration: Duration(
        milliseconds: (750 * (1 - _controller.value)).round().clamp(1, 750),
      ),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final index = widget.index;
    final backgroundColor = widget.backgroundColor;
    final nextColor = widget.nextColor;
    final onSkip = widget.onSkip;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: backgroundColor)),

          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 70,
            child: CustomPaint(painter: SideWavePainter(color: nextColor)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Petty',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: onSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Image.asset(item.image, fit: BoxFit.contain),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      item.desc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == index ? 9 : 7,
                        height: i == index ? 9 : 7,
                        decoration: BoxDecoration(
                          color: i == index
                              ? Colors.black54
                              : Colors.transparent,
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  if (_controller.value == 0) {
                    return const SizedBox.shrink();
                  }

                  return CustomPaint(
                    painter: PaintRevealPainter(
                      color: nextColor,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _startButtonTransition,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == 2
                          ? const Color(0xff4F4F4F)
                          : Colors.white70,
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: index == 2 ? const Color(0xff4F4F4F) : Colors.white,
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

class SideWavePainter extends CustomPainter {
  SideWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.75, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.75, size.height * 0.82)
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.73,
        size.width * 0.05,
        size.height * 0.70,
        size.width * 0.05,
        size.height * 0.63,
      )
      ..cubicTo(
        size.width * 0.05,
        size.height * 0.57,
        size.width * 0.75,
        size.height * 0.54,
        size.width * 0.75,
        size.height * 0.45,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SideWavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class PaintRevealPainter extends CustomPainter {
  PaintRevealPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final p = progress.clamp(0.0, 1.0);
    final left = size.width * (1 - p);

    final path = Path()
      ..moveTo(left, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(left, size.height)
      ..cubicTo(
        left - size.width * 0.08,
        size.height * 0.78,
        left + size.width * 0.08,
        size.height * 0.70,
        left,
        size.height * 0.60,
      )
      ..cubicTo(
        left - size.width * 0.08,
        size.height * 0.48,
        left + size.width * 0.08,
        size.height * 0.35,
        left,
        size.height * 0.20,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PaintRevealPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
