import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/sacred_geometry_painter.dart';

class SacredGeometryScreen extends StatelessWidget {
  const SacredGeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen dimensions to enforce a landscape 4:3 blueprint card
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Fit within screen with margins
    double width = screenWidth * 0.92;
    double height = width * 0.75;
    
    if (height > screenHeight * 0.78) {
      height = screenHeight * 0.78;
      width = height / 0.75;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5), // Light gray drafting table background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'OCTET TRIANGULUS DIAGRAM',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            size: Size(width, height),
            painter: SacredGeometryPainter(),
          ),
        ),
      ),
    );
  }
}
