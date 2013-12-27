library cinvasion.client;

import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'dart:async';

import 'package:observe/observe.dart';

part 'engine/ai.dart';
part 'engine/renderer.dart';
part 'engine/player.dart';
part 'engine/entity.dart';
part 'engine/brick.dart';
part 'engine/piece.dart';
part 'engine/controls.dart';
part 'engine/world_generator.dart';
part 'engine/board_logic.dart';

class Game {
  CanvasElement canvas;
  Renderer renderer;
  Controls controls;
  WorldGenerator worldGenerator;
  Random random;
  BoardLogic boardLogic;
  AI ai;

  // Hard-coded engine settings.
  final int blockSize = 48;
  final int columns = 30;
  final int rows = 12;
  final int maxMovement = 6;
  final int scoreLimit = 50;

  static const List<String> COLORS = const ["#5D9B00", "#00BFC2", "#C92200", "#C97C00", "#D1C300", "#0085C7", "#8361FF", "#CE1FFF"];

  // Match settings.
  List<Player> players = toObservable([]);

  // Other.
  int currentTurn = -1;
  int lastTurn = -1;
  bool canPlay = false; // Enable player controls?

  List<Entity> entities = [];
  Iterable<Piece> get pieces => entities.where((e) => e is Piece);

  // Pre-calculated useful information.
  Map<Player, List<Point>> capturedPointsByPlayer = new LinkedHashMap(); // Captured areas per player. This determines the total score.
  Map<Player, List<Point>> availablePointsByPlayer = new LinkedHashMap(); // Areas where each player can place pieces at.
  Map<Player, Point> lastMoveByPlayer = new LinkedHashMap();
  List<List<Entity>> board; // A 2d list of the game area. May contain nulls.

  bool isCurrentPositionAvailable = false;
  bool ended = false; // Has the game ended?
  Player winner;

  Game({this.canvas});

  /** Initializes the game instance. */
  void init() {
    random = new Random();
    renderer = new Renderer(this);
    controls = new Controls(this);
    boardLogic = new BoardLogic(this);
    worldGenerator = new WorldGenerator(this);
    ai = new AI(this);

    worldGenerator.generate();
    controls.onCellOver.listen((cell) {
      if (!ended && availablePointsByPlayer[currentPlayer].contains(cell)) {
        canvas.style.cursor = 'copy';
        isCurrentPositionAvailable = true;
      } else {
        canvas.style.cursor = 'not-allowed';
        isCurrentPositionAvailable = false;
      }
    });

    // Create players.
    var availableColors = new List.from(COLORS);
    players.add(
      new Player()
        ..name = 'Player'
        ..color = availableColors[random.nextInt(availableColors.length)]
        ..turnIndex = 0
        ..isComputer = false
    );

    availableColors.removeWhere((c) => players.any((p) => p.color == c));

    players.add(
      new Player()
        ..name = 'Brutal AI'
        ..color = availableColors[random.nextInt(availableColors.length)]
        ..turnIndex = 1
        ..isComputer = true
    );

    players.forEach((p) {
      entities.add(new Piece()..player = p..position = getRandomEmptyCell());
    });

    nextTurn();
  }

  Point getRandomEmptyCell() {
    var p = new Point(random.nextInt(columns), random.nextInt(rows));
    //var p = new Point(16 + random.nextInt(5), 5 + random.nextInt(5));
    if (!boardLogic.isCellEmpty(p)) return getRandomEmptyCell();
    return p;
  }

  /** Chooses the given cell. */
  void chooseCell(Point cell) {
    if (isCurrentPositionAvailable) {
      makeMove(cell);
      nextTurn();
    }
  }

  /** Process next turn. */
  void nextTurn({waitMs: 0}) {
    lastTurn = currentTurn;

    currentTurn++;

    if (currentTurn >= players.length) currentTurn = 0;

    canPlay = isPlayerMe(currentPlayer);

    updateCache();
    updateScores();

    if (currentPlayer.isComputer && ended == false) {
      waitMs = 0;
      new Timer(new Duration(milliseconds: waitMs), () {
        var w = new Stopwatch()..start;
        ai.run();
        nextTurn(waitMs: 1500 - w.elapsedMilliseconds);
      });
    }
  }

  /** Makes a move. */
  void makeMove(Point p) {
    entities.add(
      new Piece()
        ..player = currentPlayer
        ..position = p
    );

    lastMoveByPlayer[currentPlayer] = p;
  }

  /** Returns true if the given player is the one running this local instance. */
  bool isPlayerMe(Player player) => !player.isComputer;

  void updateScores() {
    players.forEach((player) {
      player.score = capturedPointsByPlayer[player].length;

      if (player.score >= scoreLimit) {
        ended = true;
        winner = player;
        canPlay = false;
      }
    });
  }

  /** Updates all kinds of caches. Needs to be called after every turn. */
  void updateCache() {
    board = [];
    for (var x = 0; x < columns; x++) {
      board.add(new List.filled(rows, null));
    }

    entities.forEach((e) {
      board[e.position.x][e.position.y] = e;
    });

    var captured = boardLogic.getCapturedPointsByPlayer();

    players.forEach((player) {
      capturedPointsByPlayer[player] = captured[player];
      availablePointsByPlayer[player] = boardLogic.getAvailablePoints(player: player);
    });
  }

  Player get currentPlayer => players[currentTurn];
}