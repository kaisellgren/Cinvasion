part of cinvasion.client;

class BoardLogic {
  Game game;

  BoardLogic(this.game);

  bool isEmptyCell(Point p) {
    for (final entity in game.entities) {
      if (p.x == entity.position.x && p.y == entity.position.y) {
        return false;
      }
    }
    return true;
  }

  bool isCellAvailable(Point p) {
    return true;
  }
}