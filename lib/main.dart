import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/vocab_service.dart';
import 'screens/flashcard_screen.dart';
import 'screens/word_list_screen.dart';
import 'screens/wordle_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B2E21),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final vocabService = await VocabService.init();
  runApp(KelimeVahasiApp(vocabService: vocabService));
}

class KelimeVahasiApp extends StatelessWidget {
  final VocabService vocabService;

  const KelimeVahasiApp({super.key, required this.vocabService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KelimeVahası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF062016),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF34D399),
          surface: Color(0xFF0B2E21),
        ),
        useMaterial3: true,
      ),
      home: MainShell(vocabService: vocabService),
    );
  }
}

class MainShell extends StatefulWidget {
  final VocabService vocabService;

  const MainShell({super.key, required this.vocabService});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      FlashcardScreen(vocabService: widget.vocabService),
      WordListScreen(vocabService: widget.vocabService),
      const WordleScreen(),
      StatsScreen(vocabService: widget.vocabService),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B2E21),
          border: Border(
            top: BorderSide(color: Color(0xFF0F3E2C), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0B2E21),
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style_rounded),
              label: 'Kartlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Sözlük',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_outlined),
              activeIcon: Icon(Icons.sports_esports_rounded),
              label: 'Kelime Avı',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'İstatistik',
            ),
          ],
        ),
      ),
    );
  }
}
