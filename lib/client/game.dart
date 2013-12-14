library cinvasion.client;

import 'dart:html';
import 'dart:math';

part 'engine/renderer.dart';
part 'engine/player.dart';
part 'engine/controls.dart';

class Game {
  CanvasElement canvas;
  Renderer renderer;
  Controls controls;

  // Hard-coded engine settings.
  final int blockSize = 48;

  // Match settings.
  List<Player> players = [];

  // Other.
  int currentTurn = -1;
  bool canPlay = false; // Enable player controls?

  Game({this.canvas}) {
    renderer = new Renderer(this);
    controls = new Controls(this);

    // Create players.
    players.add(
      new Player()
        ..color = 'green'
        ..turnIndex = 0
    );

    nextTurn();
  }

  /** Process next turn. */
  void nextTurn() {
    currentTurn++;

    if (currentTurn > players.length) currentTurn = 0;

    if (isPlayerMe(players[currentTurn])) canPlay = true;
    else canPlay = false;
  }

  /** Returns true if the given player is the one running this local instance. */
  bool isPlayerMe(Player p) {
    return true; // Let us play all turns for now, for every player.
  }
}