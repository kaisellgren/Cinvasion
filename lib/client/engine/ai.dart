part of cinvasion.client;

class AI {
  Game game;

  AI(this.game);

  void run() {
    // Find own pieces.
    var ownPieces = game.pieces.where((p) => p.player == game.currentPlayer);

    // Build a rectangle that comprises of every own piece, with a threshold of max movement.
    var topY, bottomY, leftX, rightX;
    ownPieces.forEach((p) {
      if (leftX == null || p.position.x < leftX) leftX = p.position.x;
      if (rightX == null || p.position.x > rightX) rightX = p.position.x;
      if (bottomY == null || p.position.y > bottomY) bottomY = p.position.y;
      if (topY == null || p.position.y < topY) topY = p.position.y;
    });

    // Add the threshold.
    topY = (topY - game.maxMovement).clamp(0, game.rows);
    leftX = (leftX - game.maxMovement).clamp(0, game.columns);
    rightX = (rightX + game.maxMovement).clamp(0, game.columns);
    bottomY = (bottomY + game.maxMovement).clamp(0, game.rows);

    // Iterate through every position, make a move on an emulated game, save the score of how many areas we captured.
    Map<int, List<Point>> scores = {};
    var highestScore;

    var w = new Stopwatch()..start();

    game.boardLogic.getAvailablePoints(player: game.currentPlayer).forEach((p) {
      var emulatedGame = createEmulatedGame();
      emulatedGame.makeMove(p);

      var totalScore = 0;
      emulatedGame.players.forEach((player) {
        var capturedPoints = emulatedGame.boardLogic.getCapturedPoints(player: player);
        totalScore += capturedPoints.length * (player == game.currentPlayer ? 1 : -1); // Assign negative score if the captured area was opponent's.
      });

      // Set the highest score as needed.
      if (highestScore == null || highestScore < totalScore) highestScore = totalScore;

      // Too low score? Skip.
      if (highestScore > totalScore) return;

      // Fill the scores map.
      if (scores.containsKey(totalScore) == false) scores[totalScore] = [];
      scores[totalScore].add(p);
    });

    print('after ${w.elapsedMilliseconds}');

    // Find the highest scored position. If several, randomize between them.
    var position = scores[highestScore][game.random.nextInt(scores[highestScore].length)];

    //print('AI took: ${w.elapsedMilliseconds}ms');

    game.makeMove(position);
  }

  Game createEmulatedGame() {
    var g = new Game();
    g.players = game.players;
    g.currentTurn = game.currentTurn;
    g.boardLogic = new BoardLogic(g);
    g.entities = new List.from(game.entities);
    return g;
  }
}