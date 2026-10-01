import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/vocab_service.dart';

class WordListScreen extends StatefulWidget {
  final VocabService vocabService;

  const WordListScreen({super.key, required this.vocabService});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tümü';

  final List<String> _filters = ['Tümü', 'Favoriler', 'B1', 'B2', 'C1', 'C2', 'YDS'];

  @override
  Widget build(BuildContext context) {
    final allWords = widget.vocabService.getAllWords();
    final query = _searchController.text.trim().toLowerCase();

    final filteredWords = allWords.where((w) {
      final matchesQuery = query.isEmpty ||
          w.word.toLowerCase().contains(query) ||
          w.meaning.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedFilter == 'Tümü') return true;
      if (_selectedFilter == 'Favoriler') return w.isFavorite;
      return w.level == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF062016),
      appBar: AppBar(
        title: const Text(
          'Kelime Vahası Sözlüğü',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF0B2E21),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kelime veya anlam ara...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF0B2E21),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedFilter = f),
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

          const SizedBox(height: 12),

          // Word List
          Expanded(
            child: filteredWords.isEmpty
                ? const Center(
                    child: Text(
                      'Aramanıza uygun kelime bulunamadı.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      final word = filteredWords[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2E21),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                word.level,
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              word.word,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                word.meaning,
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLeitnerDots(word.box),
                                IconButton(
                                  icon: Icon(
                                    word.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: word.isFavorite ? const Color(0xFFFBBF24) : Colors.white38,
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    await widget.vocabService.toggleFavorite(word.id);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF062016),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (word.phonetic.isNotEmpty) ...[
                                      Text(
                                        "Telaffuz: ${word.phonetic}",
                                        style: const TextStyle(
                                          color: Color(0xFF34D399),
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    const Text(
                                      'Örnek Cümle:',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\"${word.exampleEn}\"",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      word.exampleTr,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (word.synonyms.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: word.synonyms
                                            .map((s) => Chip(
                                                  label: Text(s),
                                                  backgroundColor: const Color(0xFF0B2E21),
                                                  labelStyle: const TextStyle(
                                                    color: Color(0xFF6EE7B7),
                                                    fontSize: 11,
                                                  ),
                                                  visualDensity: VisualDensity.compact,
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeitnerDots(int box) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < box;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF10B981) : Colors.white24,
          ),
        );
      }),
    );
  }
}
