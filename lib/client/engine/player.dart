part of cinvasion.client;

@observable class Player {
  String color;
  String name = 'Stranger';
  int turnIndex; // When is my turn?
  bool isComputer = false;
  int score = 0;
  int aiDifficulty = 100; // 100 = best, 0 = worst
}