part of cinvasion.client;

class Renderer {
  Game game;
  CanvasRenderingContext2D context;

  Renderer(this.game) {
    context = game.canvas.context2D;

    window.requestAnimationFrame(draw);
  }

  void draw(num highResTime) {
    drawGrid();

    window.requestAnimationFrame(draw);
  }

  void drawGrid() {
    context.strokeStyle = '#f9f9f9';

    for (var x = 0; x <= game.canvas.width; x += game.blockSize) {
      for (var y = 0; y <= game.canvas.height; y += game.blockSize) {
        context.strokeRect(x, y, game.blockSize, game.blockSize);
      }
    }
  }
}