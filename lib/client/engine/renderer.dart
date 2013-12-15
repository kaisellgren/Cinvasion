part of cinvasion.client;

class Renderer {
  Game game;
  CanvasRenderingContext2D context;

  Renderer(this.game) {
    context = game.canvas.context2D;

    window.requestAnimationFrame(draw);
  }

  void draw(num highResTime) {
    context.fillStyle = '#444';
    context.fillRect(0, 0, game.canvas.width, game.canvas.height);

    context.fillStyle = '#f0f0f0';
    context.fillRect(0, 0, game.columns * game.blockSize, game.rows * game.blockSize);

    drawGrid();
    drawEntities();
    drawCapturedPoints();
    drawAvailableCells();

    if (game.canPlay) drawControls();

    window.requestAnimationFrame(draw);
  }

  void drawControls() {
    // Draw the highlighted block.
    if (game.boardLogic.isCellEmpty(game.controls.mouseCell)) {
      context.save();
      context.fillStyle = '${game.currentPlayer.color}';
      context.globalAlpha = 0.5;
      context.fillRect(game.controls.mouseCellX * game.blockSize, game.controls.mouseCellY * game.blockSize, game.blockSize, game.blockSize);
      context.globalAlpha = 1;
      context.restore();
      game.canvas.style.cursor = 'copy';
    } else { // TODO: Move these empty checks to controls or game or somewhere else.
      game.canvas.style.cursor = 'not-allowed';
    }
  }

  void drawEntities() {
    game.entities.forEach((Entity entity) {
      if (entity is Piece) {
        context.fillStyle = '${entity.player.color}';
      } else if(entity is Brick) {
        context.fillStyle = '${entity.color}';
      }

      context.fillRect(entity.position.x * game.blockSize, entity.position.y * game.blockSize, game.blockSize, game.blockSize);
    });
  }

  void drawCapturedPoints() {
    context.save();
    context.globalAlpha = 0.05;

    game.capturedPointsByPlayer.forEach((Player player, List<Point> points) {
      context.fillStyle = '${player.color}';
      points.forEach((point) {
        context.fillRect(point.x * game.blockSize, point.y * game.blockSize, game.blockSize, game.blockSize);
      });
    });

    context.globalAlpha = 1;
    context.restore();
  }

  void drawAvailableCells() {
    context.save();
    context.globalAlpha = 0.25;

    var player = game.currentPlayer;
    context.fillStyle = '${player.color}';
    game.boardLogic.getCapturedPoints(player: player).forEach((point) {
      game.boardLogic.getAvailAblePoints(player, point).forEach((availPoint) {
          //
      });
    });

    context.globalAlpha = 1;
    context.restore();
  }

  void drawGrid() {
    context.strokeStyle = '#ddd';

    for (var x = 0; x < game.columns; x++) {
      for (var y = 0; y < game.rows; y++) {
        context.strokeRect(x * game.blockSize, y * game.blockSize, game.blockSize, game.blockSize);
      }
    }
  }
}