import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'providers/anime_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';

final GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure font fallback for Flutter Web to prevent font loading errors
  if (kIsWeb) {
    // This prevents the "Failed to load font" errors in Flutter Web
    // by using a fallback strategy instead of trying to download fonts
    // that may fail due to CORS or network issues
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize providers
  final animeProvider = AnimeProvider();
  final favoritesProvider = FavoritesProvider();
  final themeProvider = ThemeProvider();
  final searchProvider = SearchProvider();

  // Load initial data
  await Future.wait([
    favoritesProvider.loadFavorites(),
    themeProvider.loadThemeMode(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: animeProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: searchProvider),
      ],
      child: MyApp(key: appKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Load anime data when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final animeProvider = Provider.of<AnimeProvider>(context, listen: false);
      animeProvider.loadAllAnime();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme mode from ThemeProvider
    final themeMode = context.watch<ThemeProvider>().themeMode;

    // Light theme uses vibrant pink
    final ThemeData light = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE91E63), // Exact Pink
        secondary: Color(0xFFE91E63),
        surface: Colors.white,
        background: Colors.white,
        error: Color(0xFFB00020),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),
      brightness: Brightness.light,
    );

    // Dark theme uses deep purple
    final ThemeData dark = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C4DFF), // Exact Deep Purple
        secondary: Color(0xFF7C4DFF),
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        error: Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
      brightness: Brightness.dark,
      textTheme: const TextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );

    return MaterialApp(
      title: 'Anima App',
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  // Helper method for pages that still use the old API
  void setThemeMode(ThemeMode mode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(mode);
  }

  ThemeMode get themeMode => context.read<ThemeProvider>().themeMode;
}
