import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/test_page_controller.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o Consumer para ouvir as mudanças no controller
    return Scaffold(
      appBar: AppBar(
        title: const Text('Architecture Test Flow'),
      ),
      body: Center(
        child: Consumer<TestPageController>(
          builder: (context, controller, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    controller.message,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.isLoading ? null : controller.fetchGreeting,
                  child: const Text('Get Greeting'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}