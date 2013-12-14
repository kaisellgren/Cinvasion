part of cinvasion.client;

class BoardLogic {
  Game game;

  BoardLogic(this.game);

  bool isCellEmpty(Point p) {
    for (final entity in game.entities) {
      if (p.x == entity.position.x && p.y == entity.position.y) {
        return false;
      }
    }
    return true;
  }

  bool isCellAvailable(Point p) {
    return isCellEmpty(p) && !getCapturedPoints().contains(p);
  }

  /** Returns a [List] of [Point] objects representing every captured place. */
  List<Point> getCapturedPoints(Player player) {
    var pieces = game.entities.where((e) => e is Piece && e.player == player);

    var points = [];
    pieces.forEach((Piece piece) {
      // Find hits from the right.
      for (var i = piece.position.x; i < game.columns; i++) {
        var hit = pieces.firstWhere((p) => p.position == new Point(piece.position.x + i, piece.position.y), orElse: () => null);
        if (hit != null) {
          points.addAll(createPointsFromRange(piece.position, hit.position, inclusive: false));
          break;
        }
      }

      // Find hits from the left.
      for (var i = piece.position.x; i > 0; i--) {
        var hit = pieces.firstWhere((p) => p.position == new Point(piece.position.x - i, piece.position.y), orElse: () => null);
        if (hit != null) {
          points.addAll(createPointsFromRange(piece.position, hit.position, inclusive: false));
          break;
        }
      }

      // Find hits from the top.
      for (var i = piece.position.y; i > 0; i--) {
        var hit = pieces.firstWhere((p) => p.position == new Point(piece.position.x, piece.position.y - i), orElse: () => null);
        if (hit != null) {
          points.addAll(createPointsFromRange(piece.position, hit.position, inclusive: false));
          break;
        }
      }

      // Find hits from the bottom
      for (var i = piece.position.y; i < game.rows; i++) {
        var hit = pieces.firstWhere((p) => p.position == new Point(piece.position.x, piece.position.y + i), orElse: () => null);
        if (hit != null) {
          points.addAll(createPointsFromRange(piece.position, hit.position, inclusive: false));
          break;
        }
      }
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