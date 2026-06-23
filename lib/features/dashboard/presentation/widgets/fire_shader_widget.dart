import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FireShaderWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0

  const FireShaderWidget({super.key, required this.progress});

  @override
  State<FireShaderWidget> createState() => _FireShaderWidgetState();
}

class _FireShaderWidgetState extends State<FireShaderWidget> with SingleTickerProviderStateMixin {
  FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
  }

  Future<void> _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset('shaders/fire.frag');
      setState(() {
        _program = program;
      });
      _ticker.start();
    } catch (e) {
      debugPrint('Failed to load shader: $e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return const SizedBox(
        width: 150,
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return CustomPaint(
      size: const Size(150, 150),
      painter: FirePainter(
        program: _program!,
        time: _time,
        progress: widget.progress,
      ),
    );
  }
}

class FirePainter extends CustomPainter {
  final FragmentProgram program;
  final double time;
  final double progress;

  FirePainter({
    required this.program,
    required this.time,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    
    // Set uniforms based on progress
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    
    // Determine color based on progress
    Color innerColor = Colors.yellow;
    Color outerColor = Colors.orange;
    
    if (progress < 0.3) {
      innerColor = Colors.blueGrey.shade300;
      outerColor = Colors.grey.shade600;
    } else if (progress < 0.7) {
      innerColor = Colors.lightBlueAccent;
      outerColor = Colors.blue;
    } else {
      innerColor = Colors.yellow;
      outerColor = Colors.deepOrange;
    }

    // uColor1 (Inner)
    shader.setFloat(3, innerColor.r);
    shader.setFloat(4, innerColor.g);
    shader.setFloat(5, innerColor.b);
    
    // uColor2 (Outer)
    shader.setFloat(6, outerColor.r);
    shader.setFloat(7, outerColor.g);
    shader.setFloat(8, outerColor.b);

    // uIntensity
    shader.setFloat(9, 0.5 + (progress * 0.5));

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant FirePainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.progress != progress;
  }
}
