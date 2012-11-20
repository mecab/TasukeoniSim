import processing.core.*;

public enum Direction {
  UP (0, -1),
  DOWN (0, 1),
  LEFT (-1, 0),
  RIGHT (1, 0);
  
  private final int dx;
  private final int dy;

  Direction(int dx, int dy) {
    this.dx = dx;
    this.dy = dy;
  }

  public PVector asPVector() {
    return new PVector(dx, dy);
  }

  public int asInt() {
    if (this == Direction.UP) {
      return 0;
    }
    else if (this == Direction.DOWN) {
      return 1;
    }
    else if (this == Direction.LEFT) {
      return 2;
    }
    else {
      return 3;
    }
  }
}
