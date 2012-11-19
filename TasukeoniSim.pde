class Game {
  private Map map;
  private List<GameObject> objs;

  public Game(Map map) {
    objs = new ArrayList<GameObject>();
  }

  public doTurn() { // 1ターン回す
    moveTheif();
    validateTheif();
    movePolice();
    validatePolice();

    resetMovedStatus();
  }

  // 衝突を気にしないで動かしてみる
  private moveThief() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Thief)) {
        continue;
      }

      // obj が Theifのとき
      Thief thief = (Theif)obj;
      theif.move();
    }
  }

  private validateTheif() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Thief)) {
        continue;
      }

      Theif theif = (Theif)obj;
      theif.validate();
    }
  }

  private movePolice() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Thief)) {
        continue;
      }

      // obj が Theifのとき
      Thief thief = (Theif)obj;
      theif.move();
    }
  }

  private validateTheif() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Police)) {
        continue;
      }

      Police police = (Police)obj;
      police.validate();
    }
  }

  private resetMovedStatus() {
    for (Iterator<GameObject> it = objs.iterator(); it.hasNext(); ) {
      GameObject obj = it.next();
      if (! (obj instanceof Person)) {
        continue;
      }

      Person person = (Person)obj;
      person.wasMoved = false;
    }
  }
}

class Map {
  public int width;
  public int height;
  private GameObject[][] map;
  
  public Map(int width, int height) {
    this.width = width;
    this.height =height;
    _map = new GameObject[width][height];
  }

  public boolean get(int x, int y) {
    /*if (map[y][x] == null) {
      return true;
    }

    if (map[y][x] instanceof Person)) {
      if (!(Person)map[y][x].wasMoved) {
        return true;
      }
    }*/

    return map[y][x];
  }
}

class GameObject {
  public int xpos;
  public int ypos;
  
  protected Map map;

  public GameObject(int x, int y, Map map) {
    xpos = x;
    ypos = y;
    xnext = x;
    ynext = y;
    this.map = map;
  }
}

class Person extends GameObject{
  public int xnext;
  public int ynext;

  public Direction moveDicrection;
  public int moveSpeed;
  public boolean wasMoved;
  
  public Person(int x, int y, Map map) {
    super(x, y, map);
    xnext = x;
    ynext = y;
    moveSpeed = 1;
    moveDirection = numToDirection(random(4));
  }

  public move() {
    moveTo(moveDirection);
  }

  public moveTo(Direction direction) {
    PVector v = direction.asPVector();
    MoveTo(int(v.x), int(v.y));
  }

  public moveTo(Direction direction, int scale) {
    PVector v = direction.asPVector();
    MoveTo(int(v.x) * scale, int(v.y) * scale);
  }

  public moveTo(int x, int y) {
    nextx = (xpos + mapWidth + x) % mapHeight;
    nexty = (ypos + mapHeight + x) % mapWidth;
  }
}

class Thief extends Person {
  public Thief(int x, int y, Map map) {
    super(x, y, map);
  }

  // 移動したい先を見て、実際に動かしたりぶつかったらうまいこと調整する
  public void validate() {

    // TODO: 調節した先は本当に動けるの？複数回validateしてあげてもいいかもね
    
    GameObject objInTarget = map.get(nextx, nexty);

    // ポリ公だったらとりあえず逃げる
    if (objInTarget instanceof Police) {
      moveDirection = counterDirection(moveDirection);
      move();
    }

    else if (objInTarget instanceof Theif) {
      Theif theif = (Theif)objInTarget;
      // もう動いてた人がいたら諦める
      if (theif.wasMoved) {
        nextx = x;
        nexty = y;
      }
      else {
        // 動いてなかったら先にうごいちゃう
      }
    }

    else if (objInTarget != null) {
      // 壁その他。とりあえず違う場所に行く。
      Direction nextD = moveDirection;
      while (nextD != moveDirection) {
        nextD = numToDirection(random(4));
      }
      moveDirection = nextD;
      move();
    }
    
    else {
      // 運よくあいてた。そのまま動く
    }

    xpos = nextx;
    ypos = nexty;
    wasMoved = true;
  }
}

class Police extends Person {
  public Police(int x, int y, Map map) {
    super(x, y, map);
  }
}

Direction numToDirection(float d) {
  int id = int(d) % 4;
  
  switch(d) {
  case 0:
    return Direction.UP;
  case 1:
    return Direction.DOWN;
  case 2:
    return Direction.LEFT;
  case 3:
    return Direction.RIGHT;
  }
}

Direction counterDirection(Direction direction) {
  switch(direction) {
  case Direction.UP:
    return Direction.DOWN;
  case Direction.DOWN:
    return Direction.UP;
  case Direction.LEFT:
    return Direction.RIGHT;
  case Direction.RIGHT:
    return Direction.LEFT;
  }
}

void setup() {

}

void draw() {

}
