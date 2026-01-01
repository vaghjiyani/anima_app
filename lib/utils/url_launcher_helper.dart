import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for launching URLs, emails, and phone numbers
class UrlLauncherHelper {
  // Private constructor to prevent instantiation
  UrlLauncherHelper._();

  /// Opens a web URL in the default browser
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.openWebUrl('https://myanimelist.net/anime/1');
  /// ```
  static Future<void> openWebUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      rethrow;
    }
  }

  /// Opens a YouTube video
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.openYouTubeVideo('dQw4w9WgXcQ');
  /// ```
  static Future<void> openYouTubeVideo(String videoId) async {
    final String url = 'https://www.youtube.com/watch?v=$videoId';
    await openWebUrl(url);
  }

  /// Opens email client with pre-filled data
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.sendEmail(
  ///   email: 'support@animaapp.com',
  ///   subject: 'Bug Report',
  ///   body: 'I found a bug...',
  /// );
  /// ```
  static Future<void> sendEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters({
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        }),
      );

      if (!await launchUrl(emailUri)) {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      rethrow;
    }
  }

  /// Makes a phone call
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.makePhoneCall('+1234567890');
  /// ```
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (!await launchUrl(phoneUri)) {
        throw Exception('Could not launch phone dialer');
      }
    } catch (e) {
      debugPrint('Error launching phone: $e');
      rethrow;
    }
  }

  /// Opens SMS app with pre-filled message
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.sendSMS('+1234567890', 'Hello!');
  /// ```
  static Future<void> sendSMS(String phoneNumber, [String? message]) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: message != null ? 'body=$message' : null,
      );

      if (!await launchUrl(smsUri)) {
        throw Exception('Could not launch SMS app');
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
      rethrow;
    }
  }

  /// Opens MyAnimeList page for a specific anime
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.openMyAnimeListPage(1); // Cowboy Bebop
  /// ```
  static Future<void> openMyAnimeListPage(int malId) async {
    final String url = 'https://myanimelist.net/anime/$malId';
    await openWebUrl(url);
  }

  /// Helper method to encode query parameters
  static String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  /// Shows a snackbar with error message when URL launch fails
  static void showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Safely launches a URL with error handling and user feedback
  ///
  /// Example:
  /// ```dart
  /// await UrlLauncherHelper.safeLaunchUrl(
  ///   context,
  ///   'https://myanimelist.net',
  ///   errorMessage: 'Could not open MyAnimeList',
  /// );
  /// ```
  static Future<void> safeLaunchUrl(
    BuildContext context,
    String urlString, {
    String? errorMessage,
  }) async {
    try {
      await openWebUrl(urlString);
    } catch (e) {
      if (context.mounted) {
        showLaunchError(context, errorMessage ?? 'Could not open link');
      }
    }
  }
}
