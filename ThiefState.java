import processing.core.*;

public enum ThiefState {
  FREE (0),
  CAPTURING (1),
  CAPTURED (2),
  TRY (3);
  
  private final int state;

  ThiefState(int state) {
    this.state = state;
  }
}
