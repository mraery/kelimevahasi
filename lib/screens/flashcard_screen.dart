import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/vocab_service.dart';

class FlashcardScreen extends StatefulWidget {
  final VocabService vocabService;

  const FlashcardScreen({super.key, required this.vocabService});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  String _selectedLevel = 'Tümü';
  int _currentIndex = 0;
  bool _isFlipped = false;

  final List<String> _levels = ['Tümü', 'B1', 'B2', 'C1', 'C2', 'YDS'];

  @override
  Widget build(BuildContext context) {
    final allWords = widget.vocabService.getAllWords();
    final filteredWords = _selectedLevel == 'Tümü'
        ? allWords
        : allWords.where((w) => w.level == _selectedLevel).toList();

    if (_currentIndex >= filteredWords.length) {
      _currentIndex = 0;
    }

    final currentWord = filteredWords.isNotEmpty ? filteredWords[_currentIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF062016),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: Color(0xFF10B981), size: 26),
            SizedBox(width: 8),
            Text(
              'Kelime Kartları',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0B2E21),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Level filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _levels.map((lvl) {
                final isSelected = _selectedLevel == lvl;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(lvl),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedLevel = lvl;
                        _currentIndex = 0;
                        _isFlipped = false;
                      });
                    },
                    backgroundColor: const Color(0xFF0F3E2C),
                    selectedColor: const Color(0xFF10B981),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF062016) : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),

          // Progress indicator
          if (filteredWords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kelime ${_currentIndex + 1} / ${filteredWords.length}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Leitner Kutu: ${currentWord?.box ?? 1} / 5",
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // 3D Flip Card
          Expanded(
            child: currentWord == null
                ? const Center(
                    child: Text(
                      'Bu seviyede kelime bulunamadı.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => setState(() => _isFlipped = !_isFlipped),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isFlipped
                                ? [const Color(0xFF0D4733), const Color(0xFF082E20)]
                                : [const Color(0xFF104A36), const Color(0xFF0B3324)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Card Top Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF062016),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${currentWord.level} • ${currentWord.partOfSpeech.toUpperCase()}",
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    currentWord.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: currentWord.isFavorite ? const Color(0xFFFBBF24) : Colors.white38,
                                    size: 28,
                                  ),
                                  onPressed: () async {
                                    await widget.vocabService.toggleFavorite(currentWord.id);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),

                            // Main Content
                            if (!_isFlipped) ...[
                              Column(
                                children: [
                                  Text(
                                    currentWord.word,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentWord.phonetic,
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.touch_app_rounded, color: Colors.white38, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Anlamını görmek için dokunun',
                                    style: TextStyle(color: Colors.white38, fontSize: 13),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Column(
                                children: [
                                  Text(
                                    currentWord.meaning,
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF062016),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "\"${currentWord.exampleEn}\"",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          currentWord.exampleTr,
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (currentWord.synonyms.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: currentWord.synonyms.map((s) {
                                        return Chip(
                                          label: Text(s),
                                          backgroundColor: const Color(0xFF062016),
                                          labelStyle: const TextStyle(
                                            color: Color(0xFF6EE7B7),
                                            fontSize: 11,
                                          ),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.swap_horiz_rounded, color: Colors.white38, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Kelimeye dönmek için dokunun',
                                    style: TextStyle(color: Colors.white38, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Tekrar Et vs Biliyorum
          if (currentWord != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF43F5E),
                        side: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'Tekrar Et (Kutu 1)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () async {
                        await widget.vocabService.updateWordResult(currentWord.id, false);
                        setState(() {
                          _isFlipped = false;
                          _currentIndex = (_currentIndex + 1) % filteredWords.length;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: const Color(0xFF062016),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text(
                        'Biliyorum (+1 Kutu)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () async {
                        await widget.vocabService.updateWordResult(currentWord.id, true);
                        setState(() {
                          _isFlipped = false;
                          _currentIndex = (_currentIndex + 1) % filteredWords.length;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
