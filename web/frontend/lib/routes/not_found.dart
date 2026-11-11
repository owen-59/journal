import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:frontend/router.gr.dart";

@RoutePage()
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.router.push(const HomeRoute()),
          child: const Text("Page not found. Go home."),
        ),
      ),
    );
  }
}
