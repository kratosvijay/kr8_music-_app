import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SacredGeometryScreen extends StatelessWidget {
  const SacredGeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final double size = shortestSide * 0.85;

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
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRect(
            child: Align(
              alignment: const Alignment(-0.69, 0.22),
              widthFactor: 0.39,
              heightFactor: 0.52,
              child: Image.asset(
                'assets/images/blueprint.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
