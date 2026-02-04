import 'package:flutter/material.dart';

enum CucaPose {
  helpful, // Writing in book
  headphones, // Listening/Music
  hint, // Pointing up (Idea/Remind)
  success, // Thumbs up
  // alert, // TODO: Need asset for Alert
  // relax, // TODO: Need asset for Relax
}

class CucaMascot extends StatelessWidget {
  final CucaPose pose;
  final double height;
  final double? width;
  final bool animate;

  const CucaMascot({
    super.key,
    required this.pose,
    this.height = 150,
    this.width,
    this.animate = true, // Future: Add simplistic bounce/fade animation
  });

  String get _assetPath {
    switch (pose) {
      case CucaPose.helpful:
        return 'images/mascot/cuca_helpful.png';
      case CucaPose.headphones:
        return 'images/mascot/cuca_headphones.png';
      case CucaPose.hint:
        return 'images/mascot/cuca_hint.png';
      case CucaPose.success:
        return 'images/mascot/cuca_success.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if asset missing
        return Container(
          height: height,
          width: width ?? height,
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 40, color: Colors.grey),
              Text(pose.name, style: const TextStyle(fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}
