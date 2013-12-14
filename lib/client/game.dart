library cinvasion.client;

import 'dart:html';
import 'dart:math';

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
    if(boardLogic.emptyBlock(cell)) {
      entities.add(
          new Piece()
            ..player = currentPlayer
            ..position = cell
      );
    }

    nextTurn();
  }

  /** Process next turn. */
  void nextTurn() {
    currentTurn++;

    if (currentTurn >= players.length) currentTurn = 0;

    if (isPlayerMe(players[currentTurn])) canPlay = true;
    else canPlay = false;

    updateScores();
  }

  /** Returns true if the given player is the one running this local instance. */
  bool isPlayerMe(Player p) {
    return true; // Let us play all turns for now, for every player.
  }

  void updateScores() {

  }

  Player get currentPlayer => players[currentTurn];
}