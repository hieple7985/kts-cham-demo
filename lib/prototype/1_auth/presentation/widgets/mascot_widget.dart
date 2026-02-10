import 'package:flutter/material.dart';

enum MascotPose {
  ready,
  wave,
  alert,
  happy,
  confused,
  waiting,
}

class MascotWidget extends StatelessWidget {
  final MascotPose pose;
  final double height;
  final double width;

  const MascotWidget({
    super.key,
    this.pose = MascotPose.ready,
    this.height = 120,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    // In prototype, we may not have all assets yet.
    // Map poses to existing assets or use placeholders.
    // Assuming 'assets/images/mascot/' structure from previous context.

    String assetName;
    switch (pose) {
      case MascotPose.wave:
        assetName = 'cuca_wave.png'; // Hypothetical
        break;
      case MascotPose.alert:
        assetName =
            'cuca_crying.png'; // Using existing 'crying' for alert/error
        break;
      case MascotPose.happy:
        assetName = 'cuca_idea.png'; // Using existing 'idea' for happy
        break;
      case MascotPose.confused:
        assetName = 'cuca_headset.png'; // Placeholder
        break;
      case MascotPose.ready:
      default:
        assetName = 'cuca_writing.png'; // Using existing 'writing'
        break;
    }

    // Use existing path from AppAssets if possible, but for prototype we use direct string
    // to keep it self-contained or reference the core constants.
    // For now, let's try to match the filenames visible in previous file views (AppAssets).

    // Hardcoding paths based on AppAssets knowledge:
    // writing -> cuca_writing.png
    // idea -> cuca_idea.png
    // headset -> cuca_headset.png

    // If mapped correctly:
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: Image.asset(
        'images/mascot/$assetName',
        height: height,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if asset missing
          return Container(
            height: height,
            width: width,
            color: Colors.grey[300],
            child: Icon(Icons.person, size: height / 2, color: Colors.grey),
          );
        },
      ),
    );
  }
}
