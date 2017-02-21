playerObj p;

ArrayList<Environment> environmentList;
ArrayList<bullet> bulletList;
ArrayList<PImage> explosionArray;
ArrayList<enemyObj> enemyList;
int numEnvironment = 75;
int maxEnemies = 15;
int score = 0;
int counter = 0;


public float angle = 0;
int quadrant = 0;
boolean gameOver = false;
boolean gameOverAnimation = false;
int explosionIterator = 0;

PImage ships;
PImage rocks;
PImage explosion;
PImage enemy;

long start_time = -1;
long elapsed_time = 16666667;

void setup()
{
  ships = loadImage("ships.png");
  rocks = loadImage("asteroid.png");
  explosion = loadImage("explosion.png");
  enemy = loadImage("enemy.png");
  size(1250, 650);
   
  p = new playerObj();
  environmentList = new ArrayList<Environment>();
  bulletList = new ArrayList<bullet>();
  explosionArray = new ArrayList<PImage>();
  enemyList = new ArrayList<enemyObj>();
  
  for (int i = 0; i < numEnvironment; i++)
  {
    Asteroids a = new Asteroids(random(-width, 2 * width), random(-height, 2 * height));
    environmentList.add(a);
  }
  
  for (int i = 0 ; i < 6; i++)
  {
    for (int j = 0; j < 7; j++)
    {
      PImage p = explosion.get(0 * j, 100 * i, 100, 100);
      explosionArray.add(p);
    }
  }
}

void draw()
{
   background(0);
   for (Environment e : environmentList)
   {
     e.move();
     e.draw();
   }
   
   p.updateRotation();
   movement();
   checkLosingCondition();
   
   displayHealth();
   drawBullets();
   
   for (enemyObj e : enemyList)
   {
     e.simulate(elapsed_time / 1000000.0);
     e.draw();
   }
   spawnObjects();
   
   if (gameOver)
   {
     if (gameOverAnimation)
     {
       noLoop();
       fill(255, 0 , 0);
       textSize(64);
       text("Game Over", width/2 - 175,height /2);
       textSize(24);
       text("Press 'R' to play a new game.", width/2 - 160, height/2 + 100);
     }
   }
   
   if(start_time >= 0) 
    elapsed_time = System.nanoTime() - start_time;
    
  start_time = System.nanoTime();
} 

float movementSpeed = 0.25;
void movement() {
  if (movementSpeed < 2)
    {
      movementSpeed += 0.01;
    }
    float horizontalMovement, verticalMovement;
    if (quadrant == 2)
    {
      horizontalMovement = sin(angle * (PI/180)) * movementSpeed;
      verticalMovement = cos(angle * (PI/180)) * movementSpeed;
      for (Environment e : environmentList)
      {
         e.updatePosition(-horizontalMovement, verticalMovement); 
      }
      for (bullet b : bulletList)
      {
        b.updatePosition(-horizontalMovement, verticalMovement);
      }
      for (enemyObj e : enemyList)
      {
        e.updatePosition(-horizontalMovement, verticalMovement);
      }
    }
    else if (quadrant == 4)
    {
      float tempAngle = angle - 90.0;
      horizontalMovement = cos(tempAngle * (PI/180)) * movementSpeed;
      verticalMovement = sin(tempAngle * (PI/180)) * movementSpeed;
      for (Environment e : environmentList)
      {
         e.updatePosition(-horizontalMovement, -verticalMovement); 
      }
      for (bullet b : bulletList)
      {
        b.updatePosition(-horizontalMovement, -verticalMovement);
      }
      for (enemyObj e : enemyList)
      {
        e.updatePosition(-horizontalMovement, -verticalMovement);
      }
    }
    else if (quadrant == 3)
    {
      float tempAngle = 270 - angle;
      horizontalMovement = cos(tempAngle * (PI/180)) * movementSpeed;
      verticalMovement = sin(tempAngle * (PI/180)) * movementSpeed;
      for (Environment e : environmentList)
      {
         e.updatePosition(horizontalMovement, -verticalMovement); 
      }
      for (bullet b : bulletList)
      {
        b.updatePosition(horizontalMovement, -verticalMovement);
      }
      for (enemyObj e : enemyList)
      {
        e.updatePosition(horizontalMovement, -verticalMovement);
      }
    }
    else if (quadrant == 1)
    {
      float tempAngle = angle - 270;
      horizontalMovement = cos(tempAngle * (PI/180)) * movementSpeed;
      verticalMovement = sin(tempAngle * (PI/180)) * movementSpeed;
      for (Environment e : environmentList)
      {
         e.updatePosition(horizontalMovement, verticalMovement); 
      }
      for (bullet b : bulletList)
      {
        b.updatePosition(horizontalMovement, verticalMovement);
      }
      for (enemyObj e : enemyList)
      {
        e.updatePosition(horizontalMovement, verticalMovement);
      }
    }
}

void checkLosingCondition()
{
  if (p.health <= 0)
  {
    gameOver = true;
    return;
  }
  for (int i = 0; i < environmentList.size(); i++)
  {
    if (environmentList.get(i).inRange(width/2, height/2))
    {
      p.health -= 50;
      // do explosion animation
      environmentList.get(i).explode();
      environmentList.remove(i);
    }
  }
  for(int i = 0; i < bulletList.size();i++)
  {
    if (bulletList.get(i).inRange(width/2,height/2) && !(bulletList.get(i) instanceof playerBullet))
    {
      p.health -= bulletList.get(i).damage;
      bulletList.remove(i);
    }
  }
}

void displayHealth()
{
  if (p.health < 0)
  {
    p.health = 0;
  }
  fill(0, 255, 0);
  textSize(16);
  text("Health: " + p.health, 25,  25);
  text("Score: " + score, 25, 50);
}

void drawBullets()
{
  for (int i = 0; i < bulletList.size(); i++)
  {
    if (bulletList.get(i).x < -width || bulletList.get(i).x > width ||
        bulletList.get(i).y < -height || bulletList.get(i).y > height)
    {
      bulletList.remove(i);
    }
    else if (dist(width/2, height/2, bulletList.get(i).x, bulletList.get(i).y) <= 20)
    {
      p.health -= bulletList.get(i).damage;
      bulletList.remove(i);
    }
    else 
    {
      for (int j = 0; j < environmentList.size(); j++)
      {
        if (bulletList.get(i).inRange(environmentList.get(j).x, environmentList.get(j).y))
        {
          environmentList.get(j).explode();
          bulletList.remove(i);
          environmentList.remove(j);
          break;
        }
      }
      for(int k = 0; k < enemyList.size(); k++)
      {
        if ( !(bulletList.get(i) instanceof playerBullet))
          break;
          
        if (bulletList.get(i).inRange(enemyList.get(k).x, enemyList.get(k).y))
        {
          if (bulletList.get(i) instanceof playerBullet)
          {
            score += 100;
          }
          copy(explosion, 0, 200, 100, 100, int(enemyList.get(k).x) -25,int(enemyList.get(k).y) -25, 50,50);
          bulletList.remove(i);
          enemyList.remove(k);
          break;
        }
      }
    }
  }
  for (int i = 0; i < bulletList.size(); i++)
  {
    bulletList.get(i).draw();
  }
}

void spawnObjects()
{ 
  int r = int(random(1,300));
  
  float x;
  float y;
  if (r <= 1)
  {
    x = random( -width/2 - 200, -width/2 - 100);
    y = random(-height/2, height);
  }
  else if (r <= 2)
  {
    x = random(width + 100, width + 200);
    y = random(-height/2, height);
  }
  else if ( r <= 3)
  {
    x = random(-width/2, width);
    y = random(-height/2 - 200, -height/2 - 100);
  }
  else if (r <= 4)
  {
    x = random(-width/2, width);
    y = random(height + 100, height + 200);
  }
  else
  {
    return;
  }
  
  int chooser = counter % 2;
  
  if (chooser == 0)
  {
    Asteroids a = new Asteroids(x,y);
    environmentList.add(a);
    counter++;
  }
  else
  {
    counter++;
    if (enemyList.size() >= maxEnemies)
      return;
      
    enemyObj e = new enemyObj(x,y);
    enemyList.add(e);
  }
}

class gameObj {
  public float x, y;
  public int health;
}

class playerObj extends gameObj {
  playerObj() {
    health = 100;  
  }
  
  void updateRotation() 
  {
    if (!gameOver) 
    {
      float horizontalDist = mouseX - width/2;
      float verticalDist = mouseY - height/2;
    
      if (horizontalDist == 0 && verticalDist < 0)
      {
        angle = 0;  
      }
      else if (horizontalDist == 0 && verticalDist > 0)
      {
        angle = 180;  
      }
      else if (verticalDist == 0 && horizontalDist > 0)
      {
        angle = 90;
      }
      else if (verticalDist == 0 && horizontalDist < 0)
      {
        angle = 270;
      }
      else if (horizontalDist > 0 && verticalDist < 0)
      {
        quadrant = 2;
        angle = atan(abs(horizontalDist/verticalDist)) * (180/PI);
      }
      else if (horizontalDist > 0 && verticalDist > 0)
      {
        quadrant = 4;
        angle = 90 + atan(abs(verticalDist/horizontalDist)) * (180/PI);
      }
      else if (horizontalDist < 0 && verticalDist > 0)
      {
        quadrant = 3;
        angle = 180 + atan(abs(horizontalDist/verticalDist)) * (180/PI);
      }
      else if (horizontalDist < 0 && verticalDist < 0)
      {
        quadrant = 1;
        angle = 270 + atan(abs(verticalDist/horizontalDist)) * (180/PI);
      }
      
      translate(width/2, height/2);
      rotate(PI * angle / 180.0);
      copy(ships,0, 50*36, 36, 36, -18, -18, 36, 36);
      rotate(PI * (-1 * angle) / 180.0);
      translate(-width/2, -height/2);
    }
    else
    {
      if (!gameOverAnimation)
      {
        image(explosionArray.get(explosionIterator), width/2 - 50, height/2 - 50);
        explosionIterator++;
        if (explosionIterator == explosionArray.size())
        {
          gameOverAnimation = true;
        }
      }
    }
  }
}

class enemyObj extends gameObj {
  
  float maxVelocity = 0.1; // px/ms 
  
  float vx,vy; // Velocity
  float ax,ay; // Acceleration
  float fearDistance;
  
  enemyObj(float xLoc, float yLoc){
    health = 200;
    fearDistance = random(250,400);
    x = xLoc;
    y = yLoc;
  }
  void draw()
  {
    image(enemy,int(x)-19, int(y)-15, 38, 30);
  }
  void updatePosition(float deltaX, float deltaY)
  {
    x += deltaX;
    y += deltaY;
  }
  
  void simulate(float dt) {
    
    x += vx * dt;
    y += vy * dt;
    
    vx += ax * dt;
    vy += ay * dt;
    
    // Limit max velocity
    float l2 = sq(vx) + sq(vy);
    if(l2 > maxVelocity*maxVelocity) {
      l2 = sqrt(l2);
      vx *= maxVelocity / l2;
      vy *= maxVelocity / l2;
    }
    
    // Compute acceleration from scratch.
    ax = ay = 0;
    
    accelerate(dt);
    shoot();
  }
  void accelerate(float dt) {
    flee(-0.1);
  }
  
  void flee(float strength) {
      
    // Find the vector pointing away from the target, and normalize it.
    float dx = x - width/2;
    float dy = y - height/2;
    float l = dist(0,0,dx,dy);
    
    if (l <= fearDistance)
    {
      strength = 0.5;
    }
      
    if(l != 0) {
      l = sqrt(l);
      dx /= l;
      dy /= l;
    }
    
    ax += dx * strength / l;
    ay += dy * strength / l;
  }
  void shoot()
  {
    int r = int(random(1,150));
    if (dist(x,y, width/2, height/2) > 500)
      return;
      
    if (r <= 1)
    {
      enemyBullet b = new enemyBullet();
      b.x = x;
      b.y = y;
      float hori = x - width/2;
      float vert = y - height/2;
      float ang = sin(abs(vert)/abs(hori));
      
      b.horizontalMovement = b.speed * cos(ang);
      b.verticalMovement = b.speed * sin(ang);
      if (hori > 0)
      {
        b.horizontalMovement *= -1;
      }
      if (vert > 0)
      {
        b.verticalMovement *= -1;
      }
      bulletList.add(b);
    }
  }
}

class Environment extends gameObj {
  void draw(){ }
  void move() { }
  void updatePosition(float deltaX, float deltaY) { }
  boolean inRange(float a, float b) { return false;}
  void explode() { }
}

class Asteroids extends Environment {
  public float radius;
  public float xVelocity;
  public float yVelocity;
  Asteroids(float xLoc, float yLoc)
  {
    radius = random(0, 25);
    xVelocity = random(-0.2, 0.2);
    yVelocity = random(-0.2, 0.2);
    x = xLoc; //random(-width, 2 * width);
    y = yLoc; //random(-height, 2 * height);
    while(dist(x, y, width/2, height/2) < 100)
    {
      x = random(0, width);
      y = random(0, height);
    }
  }
  
  void move()
  {
      x += xVelocity; 
      y += yVelocity;
  }
  
  void draw()
  {
    image(rocks, x-30, y-30,60,60); 
  }
  
  void updatePosition(float deltaX, float deltaY)
  {
    x += deltaX;
    y += deltaY;
  }
  
  boolean inRange(float a, float b)
  {
    if ( dist(x,y, a, b) <= 30)
    {
      return true;
    }
    return false;
  }
  
  void explode() {
    for (int i = 0 ; i < 5; i++)
    {
      bullet b = new asteroidBullet(x-width/2,y-height/2);
      b.horizontalMovement = random(-4,4);
      b.verticalMovement = random(-4,4);
      bulletList.add(b);
    }
  }
}

class bullet extends gameObj {
  float horizontalMovement, verticalMovement;
  float speed;
  int damage;
  void draw() { }
  void updatePosition(float deltaX, float deltaY) { }
  boolean inRange(float a ,float b) { return false;}
}

class playerBullet extends bullet {
  playerBullet() {
    speed = 7;
    damage = 50;
     if (quadrant == 2)
    {
      horizontalMovement = (sin(angle * (PI/180)) * speed);
      verticalMovement = - (cos(angle * (PI/180)) * speed);
    }
    else if (quadrant == 4)
    {
      float tempAngle = angle - 90.0;
      horizontalMovement = ( cos(tempAngle * (PI/180)) * speed);
      verticalMovement =  (sin(tempAngle * (PI/180)) * speed);
    }
    else if (quadrant == 3)
    {
      float tempAngle = 270 - angle;
      horizontalMovement = - (cos(tempAngle * (PI/180)) * speed);
      verticalMovement =  (sin(tempAngle * (PI/180)) * speed);
    }
    else if (quadrant == 1)
    {
      float tempAngle = angle - 270;
      horizontalMovement = - (cos(tempAngle * (PI/180)) * speed);
      verticalMovement = - (sin(tempAngle * (PI/180)) * speed);
    }
    x = 2 * horizontalMovement;
    y = 2 * verticalMovement;
  }
  void draw() {
    translate(width/2, height/2);
    fill(0, 255 , 0);
    ellipse(x, y, 30, 30);
    translate(-width/2, -height/2);
  }
  void updatePosition(float deltaX, float deltaY)
  {
    x += deltaX + horizontalMovement;
    y += deltaY + verticalMovement;
  }
  
  boolean inRange(float a, float b)
  {
    if ( dist(x + width/2,y + height/2, a, b) <= 20)
    {
      return true;
    }
    return false;
  }
}

class asteroidBullet extends bullet {
 asteroidBullet(float xLoc, float yLoc) {
   speed = 7;
   damage = 15;
   x = xLoc;
   y = yLoc;
 }
 void draw() {
    translate(width/2, height/2);
    fill(128, 128, 128);
    ellipse(x, y, 15, 15);
    translate(-width/2, -height/2);
  }
  void updatePosition(float deltaX, float deltaY)
  {
    x += deltaX + horizontalMovement;
    y += deltaY + verticalMovement;
  }
  boolean inRange(float a, float b)
  {
    if ( dist(x + width/2,y + height/2, a, b) <= 25)
    {
      return true;
    }
    return false;
  }
}

class enemyBullet extends bullet {
  enemyBullet() 
  {
    speed = 7;
    damage = 15;
  }
  void draw() {
    //translate(width/2, height/2);
    fill(255, 0 , 0);
    ellipse(x, y, 10, 10);
    //translate(-width/2, -height/2);
  }
  void updatePosition(float deltaX, float deltaY)
  {
    x += deltaX + horizontalMovement;
    y += deltaY + verticalMovement;
  }
  
  boolean inRange(float a, float b)
  {
    if ( dist(x + width/2,y + height/2, a, b) <= 20)
    {
      return true;
    }
    return false;
  }
  
}

void mousePressed() 
{
  bullet b = new playerBullet();
  bulletList.add(b);
}

void keyPressed() {
  if (key == 'R' || key == 'r')
  {
    if (gameOver == false)
    {
      return;
    }
    loop();
    p.health = 100;
    score = 0;
    gameOver = false;
    gameOverAnimation = false;
    explosionIterator = 0;
    setup();
  }
}