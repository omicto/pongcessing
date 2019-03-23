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
float ball_size = 15;  // Radius
float dy = 0;  // Direction

float extMouseY = 0;
float pExtMouseY = 0;

// Global variables for the paddle
int paddle_width = 10;
int paddle_height = 60;

int dist_wall = 15;

//////////OSCP
OscP5 oscP5;
NetAddress remoteLocation;

void setup()
{

  extMouseY = width/2;
  
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
  //remoteLocation = new NetAddress("192.168.43.194",12001);
}

void draw() 
{
  background(51);
  
  ball_x += ball_dir * 1.0;
  ball_y += dy;

  // If ball has exited the screen through the right
  if(ball_x > width+ball_size) {
    // ball_x = -width/2 - ball_size;
    ball_x =  ball_size + paddle_width + 1;
    ball_y = random(0, height);
    dy = 0;
  }
  
  

  /*** Right paddle code*/
  // Constrain paddle to screen
  
  float rightPaddle_Y = constrain(extMouseY, paddle_height, height-paddle_height);

  // Test to see if the ball is touching the paddle
  float rightPy = width-dist_wall-paddle_width-ball_size;
  if (ball_x == rightPy /*    ==  */
     && ball_y > rightPaddle_Y - paddle_height - ball_size 
     && ball_y < rightPaddle_Y + paddle_height + ball_size) 
  {
    ball_dir *= -1;
    if(extMouseY != pExtMouseY) {
      dy = (extMouseY-pExtMouseY)/2.0;
      if(dy >  5) { dy =  5; }
      if(dy < -5) { dy = -5; }
    }
  }

  // Left paddle
  float leftPaddle_Y = constrain(extMouseY, paddle_height, height-paddle_height);

  // Test to see if the ball is touching the paddle
  if (ball_x == dist_wall // ==
     && ball_y > leftPaddle_Y - paddle_height - ball_size 
     && ball_y < leftPaddle_Y + paddle_height + ball_size) 
  {
    ball_dir *= -1;
    if(extMouseY != pExtMouseY) {
      dy = (extMouseY-pExtMouseY)/2.0;
      if(dy >  5) { dy =  5; }
      if(dy < -5) { dy = -5; }
    }
  } 


  /*********************************BALL CONDITIONS*******************************************/
  // If ball hits paddle or back wall, reverse direction
  if(ball_x < ball_size && ball_dir == -1) {
    ball_dir *= -1;
  }
  
  // If the ball is touching top or bottom edge, reverse direction
  if(ball_y > height-ball_size) {
    dy = dy * -1;
  }
  if(ball_y < ball_size) {
    dy = dy * -1;
  }

  /********************************END BALL CONDITIONS**********************************/

  // Draw ball
  fill(255);
  ellipse(ball_x, ball_y, ball_size, ball_size);
  
  // Draw the paddle
  fill(153);
  rect(width-dist_wall, rightPaddle_Y, paddle_width, paddle_height);
  rect(dist_wall, leftPaddle_Y, paddle_width, paddle_height);
  
  ///////// OSCP /////////////////
  /*OscMessage msg = new OscMessage("/pos");
  msg.add(mouseY);
  oscP5.send(msg,remoteLocation);*/
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/left") == true){
    //...
  }
  float y = 0;
  if(theOscMessage.checkAddrPattern("/right") == true){
     y =  theOscMessage.get(0).floatValue();
    moveRightPaddleOnDifference(y);
  }
  println("received Y:" + y + "ext: " + pExtMouseY + " mo" + extMouseY);
  
}


void moveLeftPaddle(float y){

}


/*void moveRightPaddle(float y){
    /*pExtMouseY = extMouseY;
    if(pExtMouseY <= 0) {
      extMouseY = 0;
      return;
    }
    if(pExtMouseY >= height){
      extMouseY = height;
      return;
    }

    int speedFactor = 2;

    if(y > 0){
      extMouseY += abs(y) * speedFactor;
    }
    if(y < -0.5){
      extMouseY -= abs(y) * speedFactor;
    }
    extMouseY = constrain(extMouseY, 0, 360);
}*/

void moveRightPaddleOnDifference(float dif){
    // Tweak as needed
    int speedFactor = 20;

    if(dif > 0){
      extMouseY += abs(dif) * speedFactor;
    }
    if(dif < 0){
      extMouseY -= abs(dif) * speedFactor;
    }
    extMouseY = constrain(extMouseY, 0, 360);

}
