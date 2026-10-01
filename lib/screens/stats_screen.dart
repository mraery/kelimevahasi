import 'package:flutter/material.dart';
import '../services/vocab_service.dart';

class StatsScreen extends StatefulWidget {
  final VocabService vocabService;

  const StatsScreen({super.key, required this.vocabService});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  void _showSetTargetDialog() {
    final controller = TextEditingController(
      text: widget.vocabService.getDailyTarget().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B2E21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Günlük Kelime Hedefi', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Hedef Kelime (Örn: 15)',
            labelStyle: const TextStyle(color: Colors.white60),
            filled: true,
            fillColor: const Color(0xFF062016),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: const Color(0xFF062016),
            ),
            onPressed: () async {
              final val = int.tryParse(controller.text) ?? 15;
              await widget.vocabService.setDailyTarget(val);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayLearned = widget.vocabService.getTodayLearned();
    final dailyTarget = widget.vocabService.getDailyTarget();
    final progress = dailyTarget == 0 ? 0.0 : (todayLearned / dailyTarget).clamp(0.0, 1.0);

    final boxCounts = widget.vocabService.getBoxCounts();
    final allWords = widget.vocabService.getAllWords();
    final totalWords = allWords.length;
    final masteredWords = (boxCounts[4] ?? 0) + (boxCounts[5] ?? 0);
    final masteryRate = totalWords == 0 ? 0.0 : masteredWords / totalWords;

    return Scaffold(
      backgroundColor: const Color(0xFF062016),
      appBar: AppBar(
        title: const Text(
          'Hafıza & Leitner İstatistikleri',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF0B2E21),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF10B981)),
            tooltip: 'Hedefi Düzenle',
            onPressed: _showSetTargetDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Daily Goal Ring
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B2E21), Color(0xFF0D4733)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          backgroundColor: const Color(0xFF062016),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? const Color(0xFF10B981) : const Color(0xFF34D399),
                          ),
                        ),
                        Center(
                          child: Text(
                            "%${(progress * 100).toInt()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bugünkü Kelime Hedefi',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$todayLearned / $dailyTarget Kelime",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          todayLearned >= dailyTarget
                              ? '🎉 Hedefe Ulaşıldı! Harikasın!'
                              : '${dailyTarget - todayLearned} kelime daha tekrar edin',
                          style: TextStyle(
                            color: todayLearned >= dailyTarget
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6EE7B7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mastery Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2E21),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kalıcı Hafıza Oranı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "%${(masteryRate * 100).toInt()}",
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: masteryRate,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF062016),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$masteredWords / $totalWords kelime Kutu 4 ve 5'e yükseldi.",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Leitner 5-Box Distribution Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Leitner 5-Kutu Dağılımı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildBoxRow(1, 'Kutu 1: Yeni & Tekrar Gerekenler', 'Her gün tekrar', boxCounts[1] ?? 0, totalWords, const Color(0xFFF43F5E)),
            _buildBoxRow(2, 'Kutu 2: Başlangıç Aşaması', '3 günde bir tekrar', boxCounts[2] ?? 0, totalWords, const Color(0xFFFB923C)),
            _buildBoxRow(3, 'Kutu 3: Öğrenilmekte', 'Haftada bir tekrar', boxCounts[3] ?? 0, totalWords, const Color(0xFFFBBF24)),
            _buildBoxRow(4, 'Kutu 4: Pekiştirildi', '2 haftada bir tekrar', boxCounts[4] ?? 0, totalWords, const Color(0xFF34D399)),
            _buildBoxRow(5, 'Kutu 5: Kalıcı Hafıza (Usta)', 'Ayda bir tekrar', boxCounts[5] ?? 0, totalWords, const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxRow(int boxNum, String title, String subtitle, int count, int total, Color color) {
    final pct = total == 0 ? 0.0 : count / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E21),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      boxNum.toString(),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                "$count Kelime",
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: const Color(0xFF062016),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
