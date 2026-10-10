import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;

  const FullScreenImage({
    super.key,
    this.imageUrl
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: _getImage(),
        ),
      ),
    );
  }

  ///------------------------------PRIVATE METHODS------------------------///
  Widget _getImage(){
    Widget image;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.white, size: 50),
      );
    } else {
      image = const Icon(Icons.person, color: Colors.white, size: 80);
    }

    return image;
  }
}