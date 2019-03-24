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
String [] players = {"left","right"};
int playerNumber;

/*Sensores*/
KetaiSensor sensor;

// Buttons
int shapeSize;

int rectX, rectY;
color rectColor;
color rectHighlight;

int circleX, circleY;
color circleColor;
color circleHighlight;


boolean rectOver = false;
boolean circleOver = false;

void setup()
{
  shapeSize = width/9;

  rectColor = color(224, 123, 22);
  circleColor = color(2, 120, 56);
  
  rectHighlight = color(104, 56, 9);
  circleHighlight = color(5, 73, 37);

  circleX = width/2+shapeSize/2+10;
  circleY = height/2;
  rectX = width/2-shapeSize-10;
  rectY = height/2-shapeSize/2;
  ellipseMode(CENTER);
  
  
  /////////////OSCP
  oscP5 = new OscP5(this,12000);
  // send to computer address
  remoteLocation = new NetAddress("192.168.0.11",12001);

  // Register for sensors
  sensor = new KetaiSensor(this);
  sensor.start();
}

void draw() {
  update(mouseX, mouseY);
  background(51);
  
  if (rectOver) {
    fill(rectHighlight);
  } else {
    fill(rectColor);
  }
  stroke(255);
  rect(rectX, rectY, shapeSize, shapeSize);
  
  if (circleOver) {
    fill(circleHighlight);
  } else {
    fill(circleColor);
  }
  stroke(0);
  ellipse(circleX, circleY, shapeSize, shapeSize);
}

void update(int x, int y) {
  if ( overCircle(circleX, circleY, shapeSize) ) {
    circleOver = true;
    rectOver = false;
  } else if ( overRect(rectX, rectY, shapeSize, shapeSize) ) {
    rectOver = true;
    circleOver = false;
  } else {
    circleOver = rectOver = false;
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void mousePressed() {
  if (circleOver) {
    playerNumber = 0;
    rectOver = false;
  }
  if (rectOver) {
    playerNumber = 1;
    circleOver = false;
  }
}

/*void mouseDragged(){
  //Send the current 
  OscMessage msg = new OscMessage("/right");
  msg.add(mouseY);
  oscP5.send(msg,remoteLocation);
}*/

float previousG = 0;
float currentG = 0;
float g = 0;


void onAccelerometerEvent(float x, float y, float z){
  OscMessage msg = new OscMessage("/" + players[playerNumber]);
  g = g * 0.8 + 0.2 * y; // Supuestamente elimina o reduce el valor de la gravedad en la medicion

  
  previousG = currentG;
  currentG = g;

  // Send difference between readings
  msg.add(currentG - previousG);
  
  
  oscP5.send(msg,remoteLocation);
}
