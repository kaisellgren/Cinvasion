part of cinvasion.client;

class Controls {
  Game game;

  int mouseX = 0;
  int mouseY = 0;

  int get mouseCellX => (mouseX / game.blockSize).floor();
  int get mouseCellY => (mouseY / game.blockSize).floor();

  Point get mouseCell => new Point(mouseCellX, mouseCellY);
  Point lastMouseCell;

  StreamController _onCellOverController = new StreamController.broadcast();
  Stream get onCellOver => _onCellOverController.stream;

  Controls(this.game) {
    game.canvas.onMouseMove.listen((MouseEvent e) {
      lastMouseCell = mouseCell;

      mouseX = e.clientX - game.canvas.offsetLeft;
      mouseY = e.clientY - game.canvas.offsetTop;

      e.preventDefault();

      // The user moved his mouse to another cell. Fire an event.
      // We don't want to fire if he just moves the mouse inside the same cell.
      if (lastMouseCell != mouseCell) {
        _onCellOverController.add(mouseCell);
      }
    });

    game.canvas.onClick.listen((MouseEvent e) {
      if (game.canPlay) game.chooseCell(mouseCell);

      e.preventDefault();
    });

    game.canvas.onDragStart.listen((e) => e.preventDefault());
    game.canvas.onMouseDown.listen((e) => e.preventDefault());
  }
}