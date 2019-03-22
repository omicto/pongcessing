/**
 * Collision (Pong). 
 * 
 * Move the mouse up and down to move the paddle.  aaaa
 */
 
import oscP5.*;
import netP5.*;
import ketai.sensors.*;

// Global variables for the ball
float ball_x;
float ball_y;
float ball_dir = 1;
float ball_size = 15;  // Radius
float dy = 0;  // Direction

// Global variables for the paddle
int paddle_width = 10;
int paddle_height = 60;

int dist_wall = 15;

//////////OSCP
OscP5 oscP5;
NetAddress remoteLocation;

///
String [] player = {"left","right"};

/*Sensores*/
KetaiSensor sensor;

void setup()
{
  
  println (displayWidth); 
  println (displayHeight); 
  
  
  //size(640, 360);
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  noStroke();
  smooth();
  ball_y = height/2;
  ball_x = 1;
  
  
  /////////////OSCP
  oscP5 = new OscP5(this,12000);
  // send to computer address
  remoteLocation = new NetAddress("192.168.1.110",12001);

  // Register for sensors
  sensor = new KetaiSensor(this);
  sensor.start();
}

void draw() 
{
  background(51);
  
  ball_x += ball_dir * 1.0;
  ball_y += dy;
  if(ball_x > width+ball_size) {
    ball_x = -width/2 - ball_size;
    ball_y = random(0, height);
    dy = 0;
  }
  
  
  // Constrain paddle to screen
  float paddle_y = constrain(mouseY, paddle_height, height-paddle_height);

  // Test to see if the ball is touching the paddle
  float py = width-dist_wall-paddle_width-ball_size;
  if(ball_x == py /*    ==  */
     && ball_y > paddle_y - paddle_height - ball_size 
     && ball_y < paddle_y + paddle_height + ball_size) {
    ball_dir *= -1;
    if(mouseY != pmouseY) {
      dy = (mouseY-pmouseY)/2.0;
      if(dy >  5) { dy =  5; }
      if(dy < -5) { dy = -5; }
    }
  } 
  
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

  // Draw ball
  fill(255);
  ellipse(ball_x, ball_y, ball_size, ball_size);
  
  // Draw the paddle
  fill(153);
  rect(width-dist_wall, paddle_y, paddle_width, paddle_height); 
  
  
}

/*void mouseDragged(){
  //Send the current 
  OscMessage msg = new OscMessage("/right");
  msg.add(mouseY);
  oscP5.send(msg,remoteLocation);
}*/

float previousY = 0;
float currentY = 0;
float g = 0;
void onAccelerometerEvent(float x, float y, float z){
  g = g * 0.8 + 0.2 * y; // Supuestamente elimina o reduce el valor de la gravedad en la medicion

  previousY = currentY;
  currentY = y;
  OscMessage msg = new OscMessage("/" + player[1]);
  msg.add(currentY - previousY);
  oscP5.send(msg,remoteLocation);
}
