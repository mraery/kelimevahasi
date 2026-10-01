enum LetterStatus { initial, absent, present, correct }

class WordleTarget {
  final String word;
  final String meaning;

  const WordleTarget({required this.word, required this.meaning});
}

class WordleGame {
  static const List<WordleTarget> targets = [
    WordleTarget(word: 'FOCUS', meaning: 'Odaklanmak, merkez'),
    WordleTarget(word: 'LEARN', meaning: 'Öğrenmek, bilgi edinmek'),
    WordleTarget(word: 'BUILD', meaning: 'İnşa etmek, kurmak'),
    WordleTarget(word: 'HABIT', meaning: 'Alışkanlık, huy'),
    WordleTarget(word: 'SMART', meaning: 'Akıllı, zeki, şık'),
    WordleTarget(word: 'LOGIC', meaning: 'Mantık, muhakeme'),
    WordleTarget(word: 'SHINE', meaning: 'Parlamak, ışık saçmak'),
    WordleTarget(word: 'BRAIN', meaning: 'Beyin, zeka'),
    WordleTarget(word: 'PEACE', meaning: 'Huzur, barış'),
    WordleTarget(word: 'VIVID', meaning: 'Canlı, berrak, parlak'),
    WordleTarget(word: 'FAITH', meaning: 'İnanç, güven'),
    WordleTarget(word: 'DREAM', meaning: 'Rüya, hayal etmek'),
    WordleTarget(word: 'NOBLE', meaning: 'Asil, soylu'),
    WordleTarget(word: 'QUICK', meaning: 'Hızlı, çabuk'),
    WordleTarget(word: 'BRAVE', meaning: 'Cesur, yiğit'),
    WordleTarget(word: 'SWIFT', meaning: 'Çevik, süratli'),
    WordleTarget(word: 'CRAFT', meaning: 'Ustalık, zanaat'),
    WordleTarget(word: 'HONOR', meaning: 'Onur, şeref'),
  ];

  final WordleTarget target;
  final List<String> guesses;
  String currentInput;
  bool isCompleted;
  bool hasWon;

  WordleGame({
    required this.target,
    List<String>? guesses,
    this.currentInput = '',
    this.isCompleted = false,
    this.hasWon = false,
  }) : guesses = guesses ?? [];

  static WordleGame startRandom() {
    final randTarget = (targets.toList()..shuffle()).first;
    return WordleGame(target: randTarget);
  }

  void addLetter(String char) {
    if (isCompleted || currentInput.length >= 5) return;
    currentInput += char.toUpperCase();
  }

  void deleteLetter() {
    if (isCompleted || currentInput.isEmpty) return;
    currentInput = currentInput.substring(0, currentInput.length - 1);
  }

  bool submitGuess() {
    if (isCompleted || currentInput.length != 5) return false;
    guesses.add(currentInput);
    if (currentInput == target.word) {
      isCompleted = true;
      hasWon = true;
    } else if (guesses.length >= 6) {
      isCompleted = true;
      hasWon = false;
    }
    currentInput = '';
    return true;
  }

  LetterStatus getStatus(String guess, int index) {
    if (index >= guess.length) return LetterStatus.initial;
    final char = guess[index];
    if (target.word[index] == char) {
      return LetterStatus.correct;
    }
    if (target.word.contains(char)) {
      return LetterStatus.present;
    }
    return LetterStatus.absent;
  }
}
