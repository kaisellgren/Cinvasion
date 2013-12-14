part of cinvasion.client;

class Renderer {
  Game game;
  CanvasRenderingContext2D context;

  Renderer(this.game) {
    context = game.canvas.context2D;

    window.requestAnimationFrame(draw);
  }

  void draw(num highResTime) {
    context.clearRect(0, 0, game.canvas.width, game.canvas.height);

    drawGrid();

    if (game.canPlay) drawControls();

    window.requestAnimationFrame(draw);
  }

  void drawControls() {
    // Draw the highlighted block.
    context.fillStyle = '${game.currentPlayer.color}';
    context.fillRect(game.controls.mouseCellX * game.blockSize, game.controls.mouseCellY * game.blockSize, game.blockSize, game.blockSize);
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