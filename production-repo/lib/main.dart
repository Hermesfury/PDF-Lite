import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/document_manager/data/datasources/document_local_datasource.dart';
import 'features/document_manager/presentation/screens/home_screen.dart';
import 'features/document_manager/presentation/screens/document_detail_screen.dart';
import 'features/pdf_viewer/presentation/screens/pdf_viewer_screen.dart';
import 'features/document_manager/presentation/screens/merge_selection_screen.dart';
import 'features/document_manager/presentation/screens/image_to_pdf_screen.dart';
import 'features/document_manager/presentation/screens/split_pdf_screen.dart';

/// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Main entry point
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: PdfLiteApp(),
    ),
  );
}

/// Main application widget
class PdfLiteApp extends ConsumerStatefulWidget {
  const PdfLiteApp({super.key});

  @override
  ConsumerState<PdfLiteApp> createState() => _PdfLiteAppState();
}

class _PdfLiteAppState extends ConsumerState<PdfLiteApp> {
  late final GoRouter _router;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Initializing Hive');
      await Hive.initFlutter();
      
      // Initialize local data source
      final localDataSource = DocumentLocalDataSourceImpl();
      await localDataSource.init();
      debugPrint('Hive initialized successfully');
      
      // Setup router
      debugPrint('Setting up GoRouter');
      _router = GoRouter(
        initialLocation: '/',
        errorBuilder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text('Route error: ${state.error}'),
          ),
        ),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/document/:id',
            name: 'document',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DocumentDetailScreen(documentId: id);
            },
          ),
          GoRoute(
            path: '/viewer/:id',
            name: 'viewer',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PdfViewerScreen(documentId: id);
            },
          ),
          GoRoute(
            path: '/merge',
            name: 'merge',
            builder: (context, state) => const MergeSelectionScreen(),
          ),
          GoRoute(
            path: '/image-to-pdf',
            name: 'image-to-pdf',
            builder: (context, state) => const ImageToPdfSelectionScreen(),
          ),
          GoRoute(
            path: '/split-pdf',
            name: 'split-pdf',
            builder: (context, state) => const SplitPdfScreen(),
          ),
        ],
      );
      debugPrint('GoRouter initialized successfully');
      
      // Mark as initialized
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      debugPrint('App fully initialized');
    } catch (e, stack) {
      debugPrint('Initialization error: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitialized = true; // Show error instead of loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'PDF Lite',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing PDF Lite...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_initError != null) {
      return MaterialApp(
        title: 'PDF Lite',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'FluxPDF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
