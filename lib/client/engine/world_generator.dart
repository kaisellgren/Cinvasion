part of cinvasion.client;

class WorldGenerator {
  Game game;

  double wallDensity = 0.05;

  WorldGenerator(this.game);

  void generate() {

    var averageWallLength = 5;
    for (var i = 0, amount = (game.rows * game.columns * wallDensity * (1 / averageWallLength)).floor(); i < amount; i++) {
      generateWall();
    }
  }

  /** Creates walls out of bricks */
  void generateWall() {
    var x = game.random.nextInt(game.columns);
    var y = game.random.nextInt(game.rows);

    var length = 3 + game.random.nextInt(9);
    var direction = game.random.nextInt(8); // 8 different directions to go to.

    // Walk around.
    for (var i = 0; i < length; i++) {
      if (x < game.columns && y < game.rows && x > 0 && y > 0) game.entities.add(new Brick(position: new Point(x, y)));

      if (direction == 0 || direction == 7 || direction == 1) x += 1;
      if (direction == 3 || direction == 4 || direction == 5) x -= 1;
      if (direction == 1 || direction == 2 || direction == 3) y += 1;
      if (direction == 5 || direction == 6 || direction == 7) y -= 1;

      // 50% change to switch direction, slightly.
      if (game.random.nextBool()) {
        // Which way we turn?
        direction += game.random.nextBool() ? 1 : -1;

        if (direction < 0) direction = 7;
        if (direction > 7) direction = 0;
      }
    }
  }
}