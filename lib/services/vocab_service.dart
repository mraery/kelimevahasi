import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

class VocabService {
  static const String _wordStatesKey = 'kv_word_states_v1';
  static const String _dailyTargetKey = 'kv_daily_target_v1';
  static const String _todayLearnedKey = 'kv_today_learned_v1';
  static const String _todayDateKey = 'kv_today_date_v1';

  final SharedPreferences _prefs;

  VocabService(this._prefs);

  static Future<VocabService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return VocabService(prefs);
  }

  Map<String, dynamic> _getWordStates() {
    final raw = _prefs.getString(_wordStatesKey);
    if (raw == null) return {};
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  List<WordItem> getAllWords() {
    final base = WordItem.initialWordBank;
    final states = _getWordStates();

    return base.map((w) {
      if (states.containsKey(w.id)) {
        final state = states[w.id] as Map<String, dynamic>;
        return w.copyWith(
          box: state['box'] as int? ?? 1,
          isFavorite: state['isFavorite'] as bool? ?? false,
          correctCount: state['correctCount'] as int? ?? 0,
          wrongCount: state['wrongCount'] as int? ?? 0,
        );
      }
      return w;
    }).toList();
  }

  Future<void> updateWordResult(String wordId, bool isKnown) async {
    final states = _getWordStates();
    final current = states[wordId] as Map<String, dynamic>? ?? {};

    int currentBox = current['box'] as int? ?? 1;
    int correct = current['correctCount'] as int? ?? 0;
    int wrong = current['wrongCount'] as int? ?? 0;
    bool isFav = current['isFavorite'] as bool? ?? false;

    if (isKnown) {
      currentBox = (currentBox < 5) ? currentBox + 1 : 5;
      correct++;
      _incrementDailyLearned();
    } else {
      currentBox = 1;
      wrong++;
    }

    states[wordId] = {
      'box': currentBox,
      'isFavorite': isFav,
      'correctCount': correct,
      'wrongCount': wrong,
    };

    await _prefs.setString(_wordStatesKey, json.encode(states));
  }

  Future<void> toggleFavorite(String wordId) async {
    final states = _getWordStates();
    final current = states[wordId] as Map<String, dynamic>? ?? {};

    int currentBox = current['box'] as int? ?? 1;
    int correct = current['correctCount'] as int? ?? 0;
    int wrong = current['wrongCount'] as int? ?? 0;
    bool isFav = !(current['isFavorite'] as bool? ?? false);

    states[wordId] = {
      'box': currentBox,
      'isFavorite': isFav,
      'correctCount': correct,
      'wrongCount': wrong,
    };

    await _prefs.setString(_wordStatesKey, json.encode(states));
  }

  // --- Daily Target & Progress ---
  int getDailyTarget() {
    return _prefs.getInt(_dailyTargetKey) ?? 15;
  }

  Future<void> setDailyTarget(int target) async {
    await _prefs.setInt(_dailyTargetKey, target);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  int getTodayLearned() {
    final today = _getTodayString();
    final storedDate = _prefs.getString(_todayDateKey);
    if (storedDate != today) {
      _prefs.setString(_todayDateKey, today);
      _prefs.setInt(_todayLearnedKey, 0);
      return 0;
    }
    return _prefs.getInt(_todayLearnedKey) ?? 0;
  }

  void _incrementDailyLearned() {
    final count = getTodayLearned();
    _prefs.setInt(_todayLearnedKey, count + 1);
  }

  // Box statistics
  Map<int, int> getBoxCounts() {
    final words = getAllWords();
    final map = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final w in words) {
      map[w.box] = (map[w.box] ?? 0) + 1;
    }
    return map;
  }
}
