import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder for the initial page
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Feira Digital App')));
  }
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(), // Our temporary home page
    ),
    // Example of future routes:
    // GoRoute(
    //   path: '/login',
    //   builder: (context, state) => const LoginPage(),
    // ),
  ],
  // We will implement route guarding here in the future
  redirect: (context, state) {
    // Logic to check authentication and user role will go here
    return null; // returning null means "proceed to the route"
  },
);
