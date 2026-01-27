import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

enum CucaAuthPose {
  ready,
  wave,
  alert,
  thumbsUp,
}

class CucaAuthMascot extends StatelessWidget {
  final CucaAuthPose pose;
  final double height;

  const CucaAuthMascot({
    super.key,
    required this.pose,
    this.height = 140,
  });

  String get _assetPath {
    switch (pose) {
      case CucaAuthPose.ready:
        return AppAssets.cucaWriting;
      case CucaAuthPose.wave:
        return AppAssets.cucaHeadset;
      case CucaAuthPose.alert:
        return AppAssets.cucaIdea;
      case CucaAuthPose.thumbsUp:
        return AppAssets.cucaThumbsUp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: height,
          child: const Center(child: Icon(Icons.pets, size: 48)),
        );
      },
    );
  }
}

