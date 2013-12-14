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

 /**
  * Finds the next [Entity] starting from [Point] [p] towards [direction].
  *
  * Direction can be one of: right, left, top, down, top right, bottom right, etc.
  */
  Entity findNextEntity(Point p, {direction: 'right'}) {
    // How much to increase per step.
    var xIncrease = direction.contains('right') ? 1 : (direction.contains('left') ? -1 : 0);
    var yIncrease = direction.contains('bottom') ? 1 : (direction.contains('top') ? -1 : 0);

    var i = 0;

    while (true) {
      i++;

      var nextPoint = new Point(p.x + xIncrease * i, p.y + yIncrease * i);

      // We hit the nether.
      if (nextPoint.x > game.columns) break;
      if (nextPoint.x < 0) break;
      if (nextPoint.y > game.rows) break;
      if (nextPoint.y < 0) break;

      var entity = game.entities.firstWhere((e) => e.position == nextPoint, orElse: () => null);
      if (entity != null) return entity;
    }
  }

  /** Returns a [List] of [Point] objects representing every captured place. */
  List<Point> getCapturedPoints({Player player}) {
    var pieces = game.entities.where((e) => e is Piece && (player == null || e.player == player));

    var directionsToCheck = ['right', 'bottom right', 'bottom', 'bottom left', 'left', 'top left', 'top', 'top right'];

    var points = [];
    pieces.forEach((Piece piece) {
      directionsToCheck.forEach((direction) {
        var hit = findNextEntity(piece.position, direction: direction);
        if (hit != null) points.addAll(createPointsFromRange(piece.position, hit.position, inclusive: false));
      });
    });

    return points;
  }

  /** Creates a [Point] [List] as a range from the two given points. */
  List<Point> createPointsFromRange(Point p1, Point p2, {bool inclusive: true}) {
    var list = [];

    if (inclusive) list.add(p1);

    var horizontalSize = (p1.x - p2.x).abs();
    var verticalSize = (p1.y - p2.y).abs();

    if (horizontalSize != 0 && verticalSize != 0 && horizontalSize != verticalSize) throw 'Cannot create point range from unbalanced points.';

    for (var i = 1; i < horizontalSize; i++) {
      var x = p1.x + i * (p2.x > p1.x ? 1 : -1);
      var y = p1.y + i * (p2.y > p1.y ? 1 : -1);

      if (horizontalSize == 0) x = p1.x;
      if (verticalSize == 0) y = p1.y;

      list.add(new Point(x, y));
    }

    if (inclusive) list.add(p2);

    return list;
  }
}