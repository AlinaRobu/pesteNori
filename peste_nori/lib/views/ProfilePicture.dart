import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const ProfilePicture({
    super.key,
    this.imageUrl,
    this.radius = 60,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
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

          /*Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}