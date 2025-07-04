import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class RedLottieAnim extends StatelessWidget {
  const RedLottieAnim({
    super.key,
    required this.path,
  });
  final String path;

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      path,
      // frameRate: FrameRate.max,
    );
  }
}
