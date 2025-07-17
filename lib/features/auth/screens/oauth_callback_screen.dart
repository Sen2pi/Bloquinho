
/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloquinho/core/services/oauth2_service_web.dart';


class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    print('OAuthCallbackScreen: Handling callback...');
    try {
      // Process the authentication code from the URL
      await OAuth2Service.handleWebCallback();

      print('OAuthCallbackScreen: Callback handled successfully. Navigating to root...');
      // After processing, redirect to the root to re-initialize the app state
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      print('OAuthCallbackScreen: Error handling callback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
