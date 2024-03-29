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
    drawLastMoves();

    if (game.canPlay) drawControls();

    drawScoreboard();

    if (game.ended) drawWinner();

    window.requestAnimationFrame(draw);
  }

  void drawLastMoves() {
    context.save();
    game.lastMoveByPlayer.forEach((Player player, Point p) {
      context.fillStyle = 'rgba(255, 255, 255, ${game.lastTurn == player.turnIndex ? 1 : 0.4})';
      context.beginPath();
      context.arc(p.x * game.blockSize + game.blockSize / 2, p.y * game.blockSize + game.blockSize / 2, 8, 0, 2 * PI);
      context.fill();

      if (game.lastTurn == player.turnIndex) {
        context.strokeStyle = 'rgba(0, 0, 0, 0.5)';
        context.stroke();
      }

      context.closePath();
    });
    context.restore();
  }

  void drawWinner() {
    var text = '${game.winner.name} won!';

    context.save();
    context.font = '64px sans-serif';
    context.fillStyle = 'rgba(255, 255, 255, 0.6)';
    context.fillRect(0, 0, game.canvas.width, game.canvas.height);
    context.fillStyle = '#333';
    context.fillText(text, game.canvas.width / 2 - context.measureText(text).width, game.canvas.height / 2);
    context.restore();
  }

  void drawScoreboard() {
    context.save();
    context.font = 'bold 24px sans-serif';
    var i = 0;
    game.players.forEach((p) {
      context.fillStyle = 'rgba(0, 0, 0, 0.5)';
      context.fillText('${p.name}: ${p.score}', 8 + 1, 24 + 30 * i + 1);
      context.fillStyle = p.color;
      context.fillText('${p.name}: ${p.score}', 8, 24 + 30 * i);
      i++;
    });
    context.restore();
  }

  void drawControls() {
    // Draw the highlighted block.
    if (game.isCurrentPositionAvailable) {
      context.save();
      context.fillStyle = '${game.currentPlayer.color}';
      context.globalAlpha = 0.5;
      context.fillRect(game.controls.mouseCellX * game.blockSize, game.controls.mouseCellY * game.blockSize, game.blockSize, game.blockSize);
      context.globalAlpha = 1;
      context.restore();
    }
  }

  void drawEntities() {
    game.entities.forEach((Entity entity) {
      if (entity is Piece) {
        context.fillStyle = '${entity.player.color}';
      } else if (entity is Brick) {
        context.fillStyle = '${entity.color}';
      }

      context.fillRect(entity.position.x * game.blockSize, entity.position.y * game.blockSize, game.blockSize, game.blockSize);
    });
  }

  void drawCapturedPoints() {
    context.save();
    context.globalAlpha = 0.1;

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

    var player = game.currentPlayer;
    var points = game.availablePointsByPlayer[player];

    context.fillStyle = player.color;
    context.strokeStyle = player.color;
    context.lineWidth = 2;

    points.forEach((Point p) {
      //context.fillRect(p.x * game.blockSize, p.y * game.blockSize, game.blockSize, game.blockSize);

      // Nothing above?
      if (game.boardLogic.isCellEmpty(new Point(p.x, p.y - 1)) && !points.any((p2) => p2.x == p.x && p2.y == p.y - 1)) {
        context.beginPath();
        context.moveTo(p.x * game.blockSize, p.y * game.blockSize);
        context.lineTo(p.x * game.blockSize + game.blockSize, p.y * game.blockSize);
        context.stroke();
      }

      // Nothing below?
      if (game.boardLogic.isCellEmpty(new Point(p.x, p.y + 1)) && !points.any((p2) => p2.x == p.x && p2.y == p.y + 1)) {
        context.beginPath();
        context.moveTo(p.x * game.blockSize, p.y * game.blockSize + game.blockSize);
        context.lineTo(p.x * game.blockSize + game.blockSize, p.y * game.blockSize + game.blockSize);
        context.stroke();
      }

      // Nothing on the right?
      if (game.boardLogic.isCellEmpty(new Point(p.x + 1, p.y)) && !points.any((p2) => p2.x == p.x + 1 && p2.y == p.y)) {
        context.beginPath();
        context.moveTo(p.x * game.blockSize + game.blockSize, p.y * game.blockSize);
        context.lineTo(p.x * game.blockSize + game.blockSize, p.y * game.blockSize + game.blockSize);
        context.stroke();
      }

      // Nothing on the left?
      if (game.boardLogic.isCellEmpty(new Point(p.x - 1, p.y)) && !points.any((p2) => p2.x == p.x - 1 && p2.y == p.y)) {
        context.beginPath();
        context.moveTo(p.x * game.blockSize, p.y * game.blockSize);
        context.lineTo(p.x * game.blockSize, p.y * game.blockSize + game.blockSize);
        context.stroke();
      }
    });

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