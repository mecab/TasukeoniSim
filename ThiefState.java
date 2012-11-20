import processing.core.*;

public enum ThiefState {
  FREE (0),
  CAPTURED (1),
  TRY (2);
  
  private final int state;

  ThiefState(int state) {
    this.state = state;
  }
}
