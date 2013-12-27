part of cinvasion.client;

class Direction {
  final _value;
  const Direction._internal(this._value);

  static const RIGHT = const Direction._internal(0);
  static const BOTTOM_RIGHT = const Direction._internal(1);
  static const BOTTOM = const Direction._internal(2);
  static const BOTTOM_LEFT = const Direction._internal(3);
  static const LEFT = const Direction._internal(4);
  static const TOP_LEFT = const Direction._internal(5);
  static const TOP = const Direction._internal(6);
  static const TOP_RIGHT = const Direction._internal(7);

  static const DIRECTIONS = const [RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT, TOP_LEFT, TOP, TOP_RIGHT];

  get hashCode => _value;
}

class BoardLogic {
  Game game;

  BoardLogic(this.game);

  final directionsToCheck = ['right', 'bottom right', 'bottom', 'bottom left', 'left', 'top left', 'top', 'top right'];

  bool isCellEmpty(Point p) {
    for (var entity in game.entities) {
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
  Entity findNextEntity(Point p, {Direction direction}) {
    // How much to increase per step.
    var xIncrease = direction == Direction.RIGHT || direction == Direction.BOTTOM_RIGHT || direction == Direction.TOP_RIGHT ? 1 : (direction != Direction.TOP && direction != Direction.BOTTOM ? -1 : 0);
    var yIncrease = direction == Direction.BOTTOM || direction == Direction.BOTTOM_RIGHT || direction == Direction.BOTTOM_LEFT ? 1 : (direction != Direction.LEFT && direction != Direction.RIGHT ? -1 : 0);

    var i = 0;

    if (xIncrease == 0 && yIncrease == 0) throw 'eh';

    while (true) {
      i++;

      var x = p.x + xIncrease * i;
      var y = p.y + yIncrease * i;

      // We hit the nether.
      if (x >= game.columns) break;
      if (x < 0) break;
      if (y >= game.rows) break;
      if (y < 0) break;

      var entity = game.board[x][y];
      if (entity != null) return entity;
    }
  }

  /** Returns a [List] of [Point] objects representing every captured place. */
  Set<Point> getCapturedPointsOld({Player player}) {
    var intersection = false;
    var foreignCapturedLength = 0;
    var pieces = game.entities.where((e) => e is Piece && e.player == player);
    var foreignPieces = game.entities.where((e) => e is Piece && e.player != player);
    Set<Point> foreignCapturedPoints = null;
    Set<Point> capturedIntersection = null;
    Map<Set<Point>, Set<Point>> intersectedLinesMap = new LinkedHashMap();

    var points = new Set();
    pieces.forEach((Piece piece) {
      foreignCapturedPoints = null;
      capturedIntersection = null;
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
                var foreignCapturedPointsTmp = createPointsFromRange(foreignPiece.position, foreignHit.position, inclusive: false);
                var capturedIntersectionTmp = capturedPoints.intersection(foreignCapturedPointsTmp);
                if(capturedIntersectionTmp.length > 0) {
                  intersection = true;
                  capturedIntersection = capturedIntersectionTmp;
                  foreignCapturedPoints = foreignCapturedPointsTmp;
                  if(foreignCapturedLength == 0 || foreignCapturedLength < foreignCapturedPointsTmp.length) {
                    foreignCapturedLength = foreignCapturedPointsTmp.length;
                  }
                }
              }
            });
          });
          if(!intersection ) {
            points.addAll(capturedPoints);
          } else {
            if(capturedPoints.length > foreignCapturedLength) {
              points.addAll(capturedPoints);
              intersectedLinesMap.forEach((linesKey, linesValue) {
                if(linesKey.intersection(capturedIntersection)) {
                  //We want to put back the original line that was broken
                  points.addAll(linesValue);
                }
              });
              intersectedLinesMap[capturedPoints] = foreignCapturedPoints;
            } else {
              intersectedLinesMap[foreignCapturedPoints] = capturedPoints;
            }
          }
        }
      });
    });
    return points;
  }

  Map<Player, Set<Point>> getCapturedPointsByPlayer() {
    Map<Player, List<List<Point>>> results = new LinkedHashMap(); // List of captured _lines_.
    Map<Point, bool> pointHasIntersections = new LinkedHashMap(); // Defines which points have intersections.
    Map<Point, int> pointLongestLine = new LinkedHashMap(); // The longest line of any point.
    Map<Point, List<int>> pointLineLengths = new LinkedHashMap(); // List of line lengths in a point.
    var longestLine = 0;

    // We don't want two lines from the same piece pair. This is basically a tuple (Point, Point).
    List<List<Point>> pointPairAlreadyProcessed = [];

    // Create all captured lines.
    game.players.forEach((player) {
      results[player] = [];

      game.entities.where((e) => e is Piece && e.player == player).forEach((Piece piece) {
        Direction.DIRECTIONS.forEach((direction) {
          var hit = findNextEntity(piece.position, direction: direction);
          if (hit is Piece && hit.player == player) {
            // Make sure this pair wasn't added before!
            if (pointPairAlreadyProcessed.any((List pair) => pair.contains(piece.position) && pair.contains(hit.position))) return;

            pointPairAlreadyProcessed.add([piece.position, hit.position]);

            var points = createPointsFromRange(piece.position, hit.position, inclusive: false);
            results[player].add(points);

            if (longestLine < points.length) longestLine = points.length;

            // Mark the points as 'has intersections' if needed. Also calculate the longest line for a point.
            points.forEach((p) {
              if (pointHasIntersections.containsKey(p)) pointHasIntersections[p] = true;
              else pointHasIntersections[p] = false;

              // Mark the length of the longest line.
              if (pointLongestLine[p] != null) pointLongestLine[p] = max(pointLongestLine[p], points.length);
              else pointLongestLine[p] = points.length;

              if (pointLineLengths.containsKey(p) == false) pointLineLengths[p] = [];
              pointLineLengths[p].add(points.length);
            });
          }
        });
      });
    });
    // TODO: Areas need to be captued as well!
    /*print('-----');
    print(results);*/
    // Starting from the longest line, filter out other intersecting lines that are shorter or equally long.
    for (var length = longestLine; length > 1; length--) {
      pointHasIntersections.forEach((point, has) {
        if (has && pointLongestLine[point] == length) {
          /*print('Point: $point');
          print('Len: ${pointLongestLine[point]}');*/

          // Figure out every line of every player that is concerned about this particular point.
          Map<Player, List<List<Point>>> survivedLines = new LinkedHashMap();
          Map<Player, List<List<Point>>> removedLines = new LinkedHashMap();
          var survivedPlayers = []; // Which players had their lines survived?

          results.forEach((player, lines) {
            survivedLines[player] = [];
            removedLines[player] = [];

            lines.forEach((List<Point> line) {
              // Only care about lines that intersect.
              if (line.any((p) => p == point)) {
                // Either add this line to 'removed' or 'survived' list, depending on its length.
                if (line.length == length) {
                  survivedLines[player].add(line);

                  if (survivedPlayers.contains(player)) {
                    // This player already had an intersecting line! Let's remove the intersecting point from this line.
                    line.remove(point);
                  } else {
                    survivedPlayers.add(player);
                  }
                } else {
                  removedLines[player].add(line);
                }
              }
            });
          });

          /*print('Survived lines: $survivedLines');
          print('Removed lines: $removedLines');
          print('Survived plr length: ${survivedPlayers.length}');*/

          // If multiple lines survived from multiple players, filter all out (neutralize). i.e. add to remove list.
          if (survivedPlayers.length > 1) {
            survivedLines.forEach((k, v) {
              removedLines[k].addAll(v);
            });
          }

          // Filter out the removed lines.
          removedLines.forEach((player, lines) {
            // Don't remove shorter lines if they are from the player who had the longest line.
            if (survivedPlayers.length == 1 && survivedPlayers.first == player) {
              // TODO: Remove the duplicate intersection points!

              return;
            }

            lines.forEach((line) {
              results[player].removeWhere((l) => line.every((p) => l.contains(p)));
              line.forEach((p) {
                pointLineLengths[p].remove(line.length);
                if (pointLineLengths[p] != null && pointLineLengths[p].length > 0) pointLongestLine[p] = pointLineLengths[p].reduce(max);
                else pointLongestLine[p] = 0;
              });
            });
          });
        }
      });
    }

    // Flatten results.
    var flattened = new LinkedHashMap();
    results.forEach((player, lines) {
      flattened[player] = lines.fold([], (p, c) => p..addAll(c));
    });

    return flattened;
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
}