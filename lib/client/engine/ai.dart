part of cinvasion.client;

class AI {
  Game game;

  AI(this.game);

  void run() {
    // Choose randomly.
    var p = game.getRandomEmptyCell();

    game.entities.add(
      new Piece()
        ..player = game.currentPlayer
        ..position = p
    );

    game.nextTurn();
  }
}