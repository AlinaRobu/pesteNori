import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onEditTap;

  const FullScreenImage({
    super.key,
    this.imageUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _getImage(),
            ),
          ),

          // Pencil button in the bottom-right corner
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: onEditTap,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 50,
            ),
      );
    }

    return const Icon(
      Icons.person,
      color: Colors.white,
      size: 80,
    );
  }
}