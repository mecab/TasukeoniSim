int pollX = 250;
int capturedCount = 0;

class Game {
  private Map map;
  private List<GameObject> objs;

  public Game(Map map, List<GameObject> objs) {
    this.objs = objs;
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      map.set(obj.xpos, obj.ypos, obj);
    }
    this.map = map;
    map.updateMap();
  }

  public void doTurn() { // 1ターン回す
    moveThief();
    movePolice();
    updateCaptureStatus();
    map.updateMap();
  }

  // 衝突を気にしないで動かしてみる
  private void moveThief() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Thief)) {
        continue;
      }

      // obj が Theifのとき
      Thief thief = (Thief)obj;
      thief.move();
    }
  }

  private void movePolice() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Police)) {
        continue;
      }

      // obj が Theifのとき
      Police police = (Police)obj;
      police.move();
    }
  }

  private void updateCaptureStatus() {
    capturedCount = 0;
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Thief)) {
        continue;
      }

      if (((Thief)obj).state == ThiefState.CAPTURED) {
        capturedCount++;
      }
    }
  }

  public void draw() {
    background(255, 255, 255);
    noStroke();
    pushStyle();
    ellipseMode(CENTER);

    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      obj.draw();
    }
    popStyle();
  }
}

class Map {
  public int width;
  public int height;
  private GameObject[][] map;
  private GameObject[][] nextMap;
  
  public Map(int width, int height) {
    this.width = width;
    this.height =height;
    map = new GameObject[height][width];
    nextMap = new GameObject[height][width];

  }

  public GameObject get(int x, int y) {
    return map[(y + height) % height][(x + width) % width];
  }

  public GameObject getNext(int x, int y) {
    return nextMap[(y + height) % height][(x + width) % width];
  }

  public GameObject get(int x, int y, Direction direction, int scale) {
    PVector v = direction.asPVector();
    return get(x + scale * int(v.x), y + scale * int(v.y));
  }

  public GameObject get(int x, int y, Direction direction) {
    return get(x, y, direction, 1);
  }

  public PVector set(int x, int y, GameObject obj) {
    x = (x + width) % width;
    y = (y + height) % height;
    nextMap[y][x] = obj;

    return new PVector(x, y);
  }

  public void updateMap() {
    map = nextMap;
    nextMap = new GameObject[width][height];
  }
}

abstract class GameObject {
  public int xpos;
  public int ypos;
  
  protected Map map;

  public GameObject(int x, int y, Map map) {
    xpos = x;
    ypos = y;

    this.map = map;
  }

  public abstract void draw();
}

abstract class Person extends GameObject{
  public Direction moveDirection;
  public int moveSpeed;
  
  public Person(int x, int y, Map map) {
    super(x, y, map);
    moveSpeed = 1;
    moveDirection = numToDirection(random(4));
  }

  public abstract void move();

  public void moveTo(Direction direction) {
    PVector v = direction.asPVector();
    moveTo(int(v.x), int(v.y));
  }

  public void moveTo(Direction direction, int scale) {
    PVector v = direction.asPVector();
    moveTo(int(v.x) * scale, int(v.y) * scale);
  }

  public void moveTo(int x, int y) {
    PVector normalized = map.set(xpos + x, ypos + y, this);
    xpos = int(normalized.x);
    ypos = int(normalized.y);
  }

  public boolean canMove(Direction direction) {
    return canMove(direction, 1);
  }

  public boolean canMove(Direction direction, int scale) {
    PVector v = direction.asPVector();
    GameObject obj = map.getNext(xpos + scale * int(v.x), ypos + scale * int(v.y));
    if (obj == null) {
      return true;
    }
    if (obj instanceof Person) {
      // 次のターンにはどっかに動いてるはずだから動ける
      return true;
    }
    else {
      return false;
    }
  }
}

class Thief extends Person {
  public ThiefState state;
  private Police nearestPolice;

  public Thief(int x, int y, Map map) {
    super(x, y, map);
    state = ThiefState.FREE;
  }

  public void move() {
    if (state == ThiefState.CAPTURED) {
      return;
    }

    if (state == ThiefState.CAPTURING) {
      moveSpeed = 1;
      if (xpos < pollX) {
        moveDirection = Direction.RIGHT;
      }
      else if (xpos > pollX) {
        moveDirection = Direction.LEFT;
      }
      else if (ypos < capturedCount) {
        moveDirection = Direction.DOWN;
      }
      else if (ypos > capturedCount){
        moveDirection = Direction.UP;
      }
      else {
        moveDirection = Direction.STOP;
        state = ThiefState.CAPTURED;
        return;
      }
    }

    if (state == ThiefState.FREE) {
      findNearestPolice();
      if (nearestPolice != null) {
        decideDirectionToEscapeFromPolice();
        moveSpeed = 1;
      }
      else {
        moveSpeed = 2;
      }
    }


    while(! canMove(moveDirection)) {
      moveDirection = clockwiseDirection(moveDirection);
    }
    moveTo(moveDirection);

    if (state == ThiefState.FREE && nearestPolice == null) {
      if (int(random(100)) == 0) {
        moveDirection = numToDirection(random(4));
      }
    }
  }

  public void draw() {
    pushStyle();
    if (isFree()) {
      fill(0, 255, 0);
    }
    else {
      fill(0, 128, 0);
    }
    ellipse(xpos, ypos, 10, 10);
    popStyle();
  }

  public boolean isFree() {
    return (state == ThiefState.FREE || state == ThiefState.TRY);
  }

   private void findNearestPolice() {
    List<Police> nearPolices = new ArrayList<Police>();

    for (int xx = -30; xx <= 30; xx++) {
      for (int yy = -30; yy <= 30; yy++) {
        GameObject obj = map.get(xpos + xx, ypos + yy);
        if (obj instanceof Police) {
          nearPolices.add((Police)obj);
        }
      }
    }

    nearestPolice = null;
    float nearestDist = Float.MAX_VALUE;

    if (nearPolices.size() > 0) {
      for (Iterator<Police> it = nearPolices.iterator(); it.hasNext(); ) {
        Police police = it.next();
        float dist = dist(xpos, ypos, police.xpos, police.ypos);
        if (dist < nearestDist) {
          nearestPolice = police;
          nearestDist = dist;
        }
      }
    }
  }

  private void decideDirectionToEscapeFromPolice() {
    int dx = this.xpos - nearestPolice.xpos;
    int dy = this.ypos - nearestPolice.ypos;

    if (abs(dx) > abs(dy)) {
      if (dx < 0) {
        moveDirection = Direction.LEFT;
      }
      else {
        moveDirection = Direction.RIGHT;
      }
    }
    else {
      if (dy < 0) {
        moveDirection = Direction.UP;
      }
      else {
        moveDirection = Direction.DOWN;
      }
    }
  }
}

class Police extends Person {
  public boolean isTryingCapture;
  private Thief nearestThief = null;
  int dx;
  int dy;

  public Police(int x, int y, Map map) {
    super(x, y, map);
  }

  public void move() {
    findNearestThief();
    if (nearestThief != null) {
      decideDirectionToFollowThief();
      isTryingCapture = true;
      moveSpeed = 2;
    }
    else {
      isTryingCapture = false;
      moveSpeed = 1;
    }

    while(! canMove(moveDirection)) {
      moveDirection = clockwiseDirection(moveDirection);
    }

    capture();

    moveTo(moveDirection, moveSpeed);

    if (!isTryingCapture) {
      if (int(random(100)) == 0) {
        moveDirection = numToDirection(random(4));
      }
    }
  }

  private void capture() {
    capture(Direction.UP);
    capture(Direction.RIGHT);
    capture(Direction.LEFT);
    capture(Direction.DOWN);
  }

  private void capture(Direction direction) {
    for (int i = 1; i > 0; i--) {
      GameObject obj = map.get(xpos, ypos, direction, i);
      if (obj instanceof Thief && ((Thief)obj).isFree()) {
        ((Thief)obj).state = ThiefState.CAPTURING;
      }
    }
  }

  private void findNearestThief() {
    dx = Integer.MAX_VALUE;
    dy = Integer.MAX_VALUE;
    List<Thief> nearThiefs = new ArrayList<Thief>();

    for (int xx = -30; xx <= 30; xx++) {
      for (int yy = -30; yy <= 30; yy++) {
        GameObject obj = map.get(xpos + xx, ypos + yy);
        if (obj instanceof Thief) {
          if (dist(xpos, ypos, obj.xpos, obj.ypos) > 30) {
            // 端っこで震えるの対策
            continue;
          }
          
          if (((Thief)obj).isFree()) {
            nearThiefs.add((Thief)obj);
          }
        }
      }
    }

    nearestThief = null;
    float nearestDist = 500 * 500;

    if (nearThiefs.size() > 0) {
      isTryingCapture = true;
      for (Iterator<Thief> it = nearThiefs.iterator(); it.hasNext(); ) {
        Thief thief = it.next();
        float dist = dist(xpos, ypos, thief.xpos, thief.ypos);
        if (dist < nearestDist) {
          nearestThief = thief;
          nearestDist = dist;
        }
      }
    }
  }

  private void decideDirectionToFollowThief() {
    dx = this.xpos - nearestThief.xpos;
    dy = this.ypos - nearestThief.ypos;

    boolean moveVirt;

    if (int(abs(dy)) == 0) {
      moveVirt = false;
    }
    else if (abs(dx) == 0) {
      moveVirt = true;
    }
    else {
      if (int(random(2)) == 0) {
        moveVirt = true;
      }
      else {
        moveVirt = false;
      }
    }

    if (!moveVirt) {
      if (dx > 0) {
        moveDirection = Direction.LEFT;
      }
      else {
        moveDirection = Direction.RIGHT;
      }
    }
    else {
      if (dy > 0) {
        moveDirection = Direction.UP;
      }
      else {
        moveDirection = Direction.DOWN;
      }
    }
  }

  public void draw() {
    pushStyle();
    fill(255, 0, 0);
    if (isTryingCapture) {
      ellipse(xpos, ypos, 25, 25);
    }
    else {
      ellipse(xpos, ypos, 10, 10);
    }

    if (nearestThief != null) {
      stroke(255, 0, 0);
      line(xpos, ypos, nearestThief.xpos, nearestThief.ypos);
    }

    noStroke();
    fill (255, 255, 0, 100);
    rect(xpos, ypos, 60, 60);
    popStyle();
  }
}

Direction numToDirection(float d) {
  int id = int(d) % 4;
  
  switch(id) {
  case 0:
    return Direction.UP;
  case 1:
    return Direction.DOWN;
  case 2:
    return Direction.LEFT;
  case 3:
    return Direction.RIGHT;
  default:
    return Direction.UP;
  }
}

Direction clockwiseDirection(Direction direction) {
  int id = direction.asInt();
  
  switch(id) {
  case 0:
    return Direction.RIGHT;
  case 1:
    return Direction.DOWN;
  case 2:
    return Direction.LEFT;
  case 3:
    return Direction.RIGHT;
  default:
    return Direction.UP;
  }
}

Direction counterDirection(Direction direction) {
  int id = direction.asInt();
  
  switch(id) {
  case 0:
    return Direction.DOWN;
  case 1:
    return Direction.UP;
  case 2:
    return Direction.RIGHT;
  case 3:
    return Direction.LEFT;
  default:
    return numToDirection(1 + random(4));
  }
  
}

Game game;

void setup() {
  size(500, 500);
  Map map = new Map(500, 500);
  List<GameObject> objs = new ArrayList<GameObject>();

  for (int i = 0; i < 10; i++) {
    objs.add(new Thief(int(random(500)), int(random(500)), map));
    objs.add(new Police(int(random(500)), int(random(500)), map));
  }
  game = new Game(map, objs);

}

void draw() {
  rectMode(CENTER);
  ellipseMode(CENTER);
  game.doTurn();
  game.draw();
}
