import 'package:polymer/polymer.dart';
import 'dart:html';

import '../../game.dart';

@CustomTag('x-app')
class AppElement extends PolymerElement {
  var canvas;
  var gameContainer;

  AppElement.created() : super.created() {
    canvas = shadowRoot.query('canvas');
    gameContainer = shadowRoot.query('.game-container');

    resizeCanvas();

    window.onResize.listen((_) => resizeCanvas());

    new Game(canvas: canvas);
  }

  void resizeCanvas() {
    canvas.width = gameContainer.clientWidth;
    canvas.height = gameContainer.clientHeight;
  }
}