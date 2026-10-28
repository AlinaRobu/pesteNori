import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final AssetImage? image;
  final double radius;
  final VoidCallback? onTap;

  const ProfilePicture({
    super.key,
    this.imageUrl,
    this.image,
    this.radius = 60,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    } else if(image != null){
      imageProvider = image;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(
                    Icons.person,
                    size: radius,
                    color: Colors.grey.shade500,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}