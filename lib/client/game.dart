library cinvasion.client;

import 'dart:html';
import 'dart:math';
import 'dart:collection';

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

  // Hard-coded engine settings.
  final int blockSize = 48;
  final int columns = 30;
  final int rows = 12;

  static const List<String> COLORS = const ["#5D9B00", "#00BFC2", "#C92200", "#C97C00", "#D1C300", "#0085C7", "#8361FF", "#CE1FFF"];

  // Match settings.
  List<Player> players = [];

  // Other.
  List<Entity> entities = [];
  int currentTurn = -1;
  bool canPlay = false; // Enable player controls?
  Map<Player, List<Point>> capturedPointsByPlayer = new LinkedHashMap();

  Game({this.canvas}) {
    random = new Random();
    renderer = new Renderer(this);
    controls = new Controls(this);
    boardLogic = new BoardLogic(this);
    worldGenerator = new WorldGenerator(this);

    worldGenerator.generate();

    // Create players.
    players.addAll([
      new Player()
        ..name = 'raper'
        ..color = COLORS[random.nextInt(COLORS.length)]
        ..turnIndex = 0,

      new Player()
        ..name = 'raper 2'
        ..color = COLORS[random.nextInt(COLORS.length)]
        ..turnIndex = 1
    ]);

    nextTurn();
  }

  /** Chooses the given cell. */
  void chooseCell(Point cell) {
    if (boardLogic.isCellEmpty(cell)) {
      entities.add(
        new Piece()
          ..player = currentPlayer
          ..position = cell
      );
    } else {
      window.alert('This block is already full!');
    }

    nextTurn();
  }

  /** Process next turn. */
  void nextTurn() {
    currentTurn++;

    if (currentTurn >= players.length) currentTurn = 0;

    canPlay = isPlayerMe(players[currentTurn]);

    updateCapturedPoints();
    updateScores();
  }

  /** Returns true if the given player is the one running this local instance. */
  bool isPlayerMe(Player player) {
    return true; // Let us play all turns for now, for every player.
  }

  void updateScores() {
  }

  void updateCapturedPoints() {
    players.forEach((player) {
      capturedPointsByPlayer[player] = boardLogic.getCapturedPoints(player);
    });
  }

  Player get currentPlayer => players[currentTurn];
}