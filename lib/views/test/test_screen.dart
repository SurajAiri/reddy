import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://preview.redd.it/zxnkmgsq6rvc1.jpeg?width=108&crop=smart&auto=webp&s=bd760a5a121c286f328adb66979e1c64422562d6",
              // height: 200,
              fit: BoxFit.fill,
              width: double.maxFinite,
            ),
          ],
        ),
      ),
    );
  }
}
