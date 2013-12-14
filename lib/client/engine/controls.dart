part of cinvasion.client;

class Controls {
  Game game;

  int mouseX = 0;
  int mouseY = 0;

  int get mouseCellX => (mouseX / game.blockSize).floor();
  int get mouseCellY => (mouseY / game.blockSize).floor();

  Point get mouseCell => new Point(mouseCellX, mouseCellY);

  Controls(this.game) {
    game.canvas.onMouseMove.listen((MouseEvent e) {
      mouseX = e.clientX - game.canvas.offsetLeft;
      mouseY = e.clientY - game.canvas.offsetTop;
    });

    game.canvas.onClick.listen((MouseEvent e) {
      if (game.canPlay) game.chooseCell(mouseCell);
    });
  }
}