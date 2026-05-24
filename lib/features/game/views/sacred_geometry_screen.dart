import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/sacred_geometry_painter.dart';

class SacredGeometryScreen extends StatelessWidget {
  const SacredGeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final double size = shortestSide * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8), // Light gray background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'OCTET TRIANGULUS',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size(size, size),
            painter: SacredGeometryPainter(),
          ),
        ),
      ),
    );
  }
}
