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

  public void draw() {
    background(255, 255, 255);
    noStroke();
    pushStyle();
    ellipseMode(CENTER);
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (obj instanceof Police) {
        fill(255, 0, 0);
        ellipse(obj.xpos, obj.ypos, 10, 10);
      }
      else if (obj instanceof Thief) {
        fill(0, 255, 0);
        ellipse(obj.xpos, obj.ypos, 10, 10);
      }
      else {
        fill(0, 0, 255);
        ellipse(obj.xpos, obj.ypos, 10, 10);
      }
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

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        if (! (get(x, y) instanceof Person)) {
          set(x, y, get(x, y));
        }
      }
    }
  }

  public GameObject get(int x, int y) {
    return map[(y + height) % height][(x + width) % width];
  }

  public void set(int x, int y, GameObject obj) {
    nextMap[(y + height) % height][(x + width) % width] = obj;
  }

  public void updateMap() {
    map = nextMap;
    nextMap = new GameObject[width][height];
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        if (!(get(x, y) instanceof Person)) {
          set(x, y, get(x, y));
        }
      }
    }
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
    xpos = (xpos + map.width + x) % map.width;
    ypos = (ypos + map.height + y) % map.height;
    map.set(x, y, this);
  }

  public boolean canMove(Direction direction) {
    PVector v = direction.asPVector();
    GameObject obj = map.get(int(xpos + v.x), int(ypos + v.y));
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
  public Thief(int x, int y, Map map) {
    super(x, y, map);
  }

  public void move() {
    while(! canMove(moveDirection)) {
      moveDirection = clockwiseDirection(moveDirection);
    }
    moveTo(moveDirection);
  }
}

class Police extends Person {
  public Police(int x, int y, Map map) {
    super(x, y, map);
  }

  public void move() {
    while(! canMove(moveDirection)) {
      moveDirection = clockwiseDirection(moveDirection);
    }
    moveTo(moveDirection);
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
  game.doTurn();
  game.draw();
}
