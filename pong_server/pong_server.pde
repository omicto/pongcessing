/**
 * Collision (Pong). 
 * 
 * Move the mouse up and down to move the paddle.  
 */
 
import oscP5.*;
import netP5.*;

// Global variables for the ball
float ball_x;
float ball_y;
float ball_dir = 1;
float BALL_SIZE = 15;  // Radius
float dy = 0;  // Direction
int DIST_WALL = 15;


//////////OSCP
OscP5 oscP5;
NetAddress remoteLocation;


Paddle izquierdo;
Paddle derecho;

void setup()
{

  izquierdo = new Paddle(10, 60, Paddle.IZQUIERDO);
  derecho = new Paddle(10, 60, Paddle.DERECHO);

  //extMouseY_R = width/2;
  
  println (displayWidth); 
  println (displayHeight); 
  
  
  size(640, 360);
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  noStroke();
  smooth();
  ball_y = height/2;
  ball_x = width/2;
  
  
  /////////////OSCP
  oscP5 = new OscP5(this,12001);
  // send to computer address
  //remoteLocation = new NetAddress("192.168.0.2",12001);
}

void draw() 
{
  background(51);
  

  ball_x += ball_dir * 1.0;
  ball_y += dy;

  // If ball has exited the screen
  if(ball_x > width+BALL_SIZE || ball_x < 0 - BALL_SIZE) {
    // ball_x = -width/2 - BALL_SIZE;
    ball_x =  width/2;
    ball_y = random(0, height);
    dy = 0;
  }
  
 /*** Right paddle code*/
 
  if (derecho.isBallTouching()) 
  {
    ball_dir *= -1;
    if(derecho.hasPaddleMoved()) {
      dy = derecho.paddleMovement()/2.0;
      if(dy >  5) { dy =  5; }
      if(dy < -5) { dy = -5; }
    }
  }
  
  // Left paddle
  // Test to see if the ball is touching the paddle
  if (izquierdo.isBallTouching()) 
  {
    ball_dir *= -1;
    if(izquierdo.hasPaddleMoved()) {
      dy = izquierdo.paddleMovement()/2.0;
      if(dy >  5) { dy =  5; }
      if(dy < -5) { dy = -5; }
    }
  }
  


  /*********************************BALL CONDITIONS*******************************************/

  
  // If the ball is touching top or bottom edge, reverse direction
  if(ball_y > height-BALL_SIZE) {
    dy = dy * -1;
  }
  if(ball_y < BALL_SIZE) {
    dy = dy * -1;
  }

  /********************************END BALL CONDITIONS**********************************/

  // Draw ball
  fill(255);
  ellipse(ball_x, ball_y, BALL_SIZE, BALL_SIZE);
  
  // Draw the paddles
  izquierdo.display();
  derecho.display();
  

}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  float dif =  theOscMessage.get(0).floatValue();
  if(theOscMessage.checkAddrPattern("/left") == true){
    izquierdo.move(dif);
  }
  if(theOscMessage.checkAddrPattern("/right") == true){
    derecho.move(dif);
  }
  println("received Y:" + dif);
}

class Paddle{
  final static int IZQUIERDO = 0;
  final static int DERECHO = 1;

  int lado;
  float y;
  float previousY;
  int paddleWidth;
  int paddleHeight;
  float py;
  int speedFactor = 20;
  float extMovement = 0;

  Paddle(int paddleWidth, int paddleHeight, int lado){
    y = previousY= height/2;
    this.paddleWidth = paddleWidth;
    this.paddleHeight = paddleHeight;
    this.lado = lado;

    if(this.lado == Paddle.DERECHO){
      py = width - DIST_WALL - this.paddleWidth - BALL_SIZE;
    } else if(this.lado == Paddle.IZQUIERDO){
      py = DIST_WALL + this.paddleWidth ;
    }
  }

  boolean isBallTouching(){
    return (ball_x == py /*    ==  */
        && ball_y > this.y - paddleHeight - BALL_SIZE 
        && ball_y < this.y + paddleHeight + BALL_SIZE);
  }

  float paddleMovement(){
    return (y - previousY);
  }

  boolean hasPaddleMoved(){
    return y != previousY;
  }

  void move(float dif){
    if(dif > 0){
      extMovement += abs(dif) * speedFactor;
    }
    if(dif < 0){
      extMovement -= abs(dif) * speedFactor;
    }
    extMovement = constrain(extMovement, 0, 360);

    previousY = y;
    y = constrain(extMovement, paddleHeight, height-paddleHeight);
  }

  void display(){
    float x = 0;
    if(lado == Paddle.IZQUIERDO) x = DIST_WALL;
    if(lado == Paddle.DERECHO) x = width - DIST_WALL;
    
    fill(153);
    rect(x, y, paddleWidth, paddleHeight);
  }

}
