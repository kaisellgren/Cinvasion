part of cinvasion.client;

class BoardLogic {
  Game game;

  BoardLogic(this.game);

  final directionsToCheck = ['right', 'bottom right', 'bottom', 'bottom left', 'left', 'top left', 'top', 'top right'];

  bool isCellEmpty(Point p) {
    for (final entity in game.entities) {
      if (p.x == entity.position.x && p.y == entity.position.y) {
        return false;
      }
    }

    return p.x < game.columns && p.y < game.rows;
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
  Set<Point> getCapturedPoints({Player player}) {
    var intersection = false;
    var foreignCapturedLength = 0;
    var pieces = game.entities.where((e) => e is Piece && e.player == player);
    var foreignPieces = game.entities.where((e) => e is Piece && e.player != player);

    var points = new Set();
    pieces.forEach((Piece piece) {
      intersection = false;
      directionsToCheck.forEach((direction) {
        var hit = findNextEntity(piece.position, direction: direction);
        if (hit is Piece && hit.player == player) {
          var capturedPoints = createPointsFromRange(piece.position, hit.position, inclusive: false);
          //Check for other intersections
          foreignPieces.forEach((Piece foreignPiece) {
            directionsToCheck.forEach((foreignDirection) {
              var foreignHit = findNextEntity(foreignPiece.position, direction: foreignDirection);
              if (foreignHit is Piece && foreignHit.player == foreignPiece.player) {
                var foreignCapturedPoints = createPointsFromRange(foreignPiece.position, foreignHit.position, inclusive: false);
                var capturedIntersection = capturedPoints.intersection(foreignCapturedPoints);
                if(capturedIntersection.length > 0) {
                  intersection = true;
                  if(foreignCapturedLength == 0 || foreignCapturedLength < foreignCapturedPoints.length) {
                    foreignCapturedLength = foreignCapturedPoints.length;
                  }
                }
              }
            });
          });
          if(!intersection ) {
            points.addAll(capturedPoints);
          } else {
            if(capturedPoints.length > foreignCapturedLength)
              points.addAll(capturedPoints);
          }
        }
      });
    });
    return points;
  }

  /** Creates a [Point] [Set] as a range from the two given points. */
  Set<Point> createPointsFromRange(Point p1, Point p2, {bool inclusive: true}) {
    var points = new Set();

    if (inclusive) points.add(p1);

    var horizontalSize = (p1.x - p2.x).abs();
    var verticalSize = (p1.y - p2.y).abs();

    if (horizontalSize != 0 && verticalSize != 0 && horizontalSize != verticalSize) throw 'Cannot create point range from unbalanced points.';

    for (var i = 1; i < max(horizontalSize, verticalSize); i++) {
      var x = p1.x + i * (p2.x > p1.x ? 1 : -1);
      var y = p1.y + i * (p2.y > p1.y ? 1 : -1);

      if (horizontalSize == 0) x = p1.x;
      if (verticalSize == 0) y = p1.y;

      points.add(new Point(x, y));
    }

    if (inclusive) points.add(p2);

    return points;
  }

  /** Creates a [List] of [Point] objects from the given rectangle corners. */
  List<Point> createPointsFromRectangle(Point a, Point b) {
    var points = [];

    for (var x = a.x; x < b.x; x++) {
      for (var y = a.y; y < b.y; y++) {
        points.add(new Point(x, y));
      }
    }

    return points;
  }

  /** Returns a [List] of [Point] objects representing available blocks where the player can make his next move **/
  List<Point> getAvailablePoints({Player player}) {
    var points = new Set();
    var playerPoints = game.pieces.where((p) => p.player == player).map((p) => p.position);

    playerPoints.forEach((Point p) {
      // Create a rectangle of points around this.
      var rectangle = createPointsFromRectangle(new Point(p.x - game.maxMovement, p.y - game.maxMovement), new Point(p.x + game.maxMovement, p.y + game.maxMovement));

      // Add to the set, filter out non-empty cells.
      points.addAll(rectangle.where((p) => isCellEmpty(p) && p.x >= 0 && p.x < game.columns && p.y >= 0 && p.y < game.rows));
    });

    return points;
  }

  List<Point> getAvailablePointsPerDirection(Point p, {direction: 'right'}) {
    // How much to increase per step.
    var xIncrease = direction.contains('right') ? 1 : (direction.contains('left') ? -1 : 0);
    var yIncrease = direction.contains('bottom') ? 1 : (direction.contains('top') ? -1 : 0);
    var cells = [];
    for(var i = 0; i <= game.maxMovement; i++) {
      var nextPoint = new Point(p.x + xIncrease * i, p.y + yIncrease * i);

      // We hit the nether.
      if (nextPoint.x > game.columns) break;
      if (nextPoint.x < 0) break;
      if (nextPoint.y > game.rows) break;
      if (nextPoint.y < 0) break;

      if (this.isCellEmpty(nextPoint)) {
        cells.add(nextPoint);
      }
    }
    return cells;
  }
}