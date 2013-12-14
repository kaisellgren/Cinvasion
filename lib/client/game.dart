library cinvasion.client;

import 'dart:html';

part 'engine/renderer.dart';

class Game {
  CanvasElement canvas;
  Renderer renderer;

  // Settings.
  int blockSize = 48;

  Game({this.canvas}) {
    renderer = new Renderer(this);
  }
}