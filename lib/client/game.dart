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

  static const List<String> COLORS = const ["#5D9B00", "#00BFC2", "#C92200", "#C97C00", "#D1C300", "#0085C7", "#8361FF", "#CE1FFF"];

  // Match settings.
  List<Player> players = toObservable([]);

  // Other.
  int currentTurn = -1;
  bool canPlay = false; // Enable player controls?

  List<Entity> entities = [];
  Iterable<Piece> get pieces => entities.where((e) => e is Piece);

  // Pre-calculated useful information.
  Map<Player, List<Point>> capturedPointsByPlayer = new LinkedHashMap(); // Captured areas per player. This determines the total score.
  Map<Player, List<Point>> availablePointsByPlayer = new LinkedHashMap(); // Areas where each player can place pieces at.

  bool isCurrentPositionAvailable = false;

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
      if (availablePointsByPlayer[currentPlayer].contains(cell)) {
        canvas.style.cursor = 'copy';
        isCurrentPositionAvailable = true;
      } else {
        canvas.style.cursor = 'not-allowed';
        isCurrentPositionAvailable = false;
      }
    });

    // Create players.
    players.addAll([
      new Player()
        ..name = 'Stan or Kai'
        ..color = COLORS[random.nextInt(COLORS.length)]
        ..turnIndex = 0,

      new Player()
        ..name = 'Computer'
        ..color = COLORS[random.nextInt(COLORS.length)]
        ..turnIndex = 1
        ..isComputer = true
    ]);

    entities.add(new Piece()..player = players[0]..position = getRandomEmptyCell());
    entities.add(new Piece()..player = players[1]..position = getRandomEmptyCell());

    nextTurn();
  }

  Point getRandomEmptyCell() {
    var p = new Point(random.nextInt(columns), random.nextInt(rows));
    if (!boardLogic.isCellEmpty(p)) return getRandomEmptyCell();
    return p;
  }

  /** Chooses the given cell. */
  void chooseCell(Point cell) {
    if (isCurrentPositionAvailable) {
      entities.add(
        new Piece()
          ..player = currentPlayer
          ..position = cell
      );

      nextTurn();
    }
  }

  /** Process next turn. */
  void nextTurn() {
    currentTurn++;

    if (currentTurn >= players.length) currentTurn = 0;

    canPlay = isPlayerMe(currentPlayer);

    updateCache();
    updateScores();

    if (currentPlayer.isComputer) ai.run();
  }

  void makeMove(Point p) {
    entities.add(
      new Piece()
        ..player = currentPlayer
        ..position = p
    );
  }

  /** Returns true if the given player is the one running this local instance. */
  bool isPlayerMe(Player player) => !player.isComputer;

  void updateScores() {
    players.forEach((player) {
      player.score = capturedPointsByPlayer[player].length;
    });
  }

  void updateCache() {
    players.forEach((player) {
      capturedPointsByPlayer[player] = boardLogic.getCapturedPoints(player: player);
      availablePointsByPlayer[player] = boardLogic.getAvailablePoints(player: player);
    });
  }

  Player get currentPlayer => players[currentTurn];
}