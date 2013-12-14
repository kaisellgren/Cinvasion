part of cinvasion.client;

class Controls {
  Game game;

  int mouseX;
  int mouseY;

  int get cellX => (mouseX / game.blockSize).floor();
  int get cellY => (mouseY / game.blockSize).floor();

  Controls(this.game) {
    game.canvas.onMouseMove.listen((MouseEvent e) {
      mouseX = e.clientX - game.canvas.offsetLeft;
      mouseY = e.clientY - game.canvas.offsetTop;
    });
  }
}