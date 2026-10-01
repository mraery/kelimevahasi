import 'package:flutter/material.dart';
import '../models/wordle.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  late WordleGame _game;

  final List<List<String>> _keyboard = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL'],
  ];

  @override
  void initState() {
    super.initState();
    _game = WordleGame.startRandom();
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'ENTER') {
        _game.submitGuess();
      } else if (key == 'DEL') {
        _game.deleteLetter();
      } else {
        _game.addLetter(key);
      }
    });
  }

  Color _getTileColor(String letter, LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF10B981);
      case LetterStatus.present:
        return const Color(0xFFFBBF24);
      case LetterStatus.absent:
        return const Color(0xFF1E293B);
      case LetterStatus.initial:
        return letter.isNotEmpty ? const Color(0xFF0F3E2C) : const Color(0xFF0B2E21);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062016),
      appBar: AppBar(
        title: const Text(
          'Kelime Avı (Wordle)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF0B2E21),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF10B981)),
            tooltip: 'Yeni Oyun',
            onPressed: () {
              setState(() {
                _game = WordleGame.startRandom();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0B2E21),
            child: const Center(
              child: Text(
                '5 harfli gizli İngilizce kelimeyi 6 denemede bulun!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 6x5 Grid
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (rowIndex) {
                    final isCurrentRow = rowIndex == _game.guesses.length;
                    final guess = rowIndex < _game.guesses.length
                        ? _game.guesses[rowIndex]
                        : (isCurrentRow ? _game.currentInput : '');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (colIndex) {
                          final char = colIndex < guess.length ? guess[colIndex] : '';
                          LetterStatus status = LetterStatus.initial;
                          if (rowIndex < _game.guesses.length) {
                            status = _game.getStatus(_game.guesses[rowIndex], colIndex);
                          }

                          return Container(
                            width: 52,
                            height: 52,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _getTileColor(char, status),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCurrentRow && char.isNotEmpty
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF10B981).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              char,
                              style: TextStyle(
                                color: status == LetterStatus.present
                                    ? const Color(0xFF062016)
                                    : Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Game Result Banner
          if (_game.isCompleted)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _game.hasWon
                      ? [const Color(0xFF065F46), const Color(0xFF047857)]
                      : [const Color(0xFF881337), const Color(0xFF9F1239)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _game.hasWon ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _game.hasWon ? 'Tebrikler! Bildiniz! 🎉' : 'Kelime: ${_game.target.word}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Anlamı: ${_game.target.meaning}",
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF062016),
                    ),
                    onPressed: () {
                      setState(() {
                        _game = WordleGame.startRandom();
                      });
                    },
                    child: const Text('Yeniden', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Keyboard
          Container(
            padding: const EdgeInsets.only(bottom: 20, top: 4),
            child: Column(
              children: _keyboard.map((row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) {
                    final isSpecial = key == 'ENTER' || key == 'DEL';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
                      child: Material(
                        color: isSpecial ? const Color(0xFF10B981) : const Color(0xFF0F3E2C),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => _onKeyPressed(key),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: isSpecial ? 54 : 32,
                              minHeight: 44,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: isSpecial && key == 'DEL'
                                ? const Icon(Icons.backspace_outlined, size: 18, color: Color(0xFF062016))
                                : Text(
                                    key,
                                    style: TextStyle(
                                      color: isSpecial ? const Color(0xFF062016) : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSpecial ? 11 : 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
