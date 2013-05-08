//kinect controlled aiflowers by Toby Dai - tobydai.com
//needs an OSC input device such as an iphone with touch OSC

import SimpleOpenNI.*;
SimpleOpenNI  context;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

boolean       autoCalib=true;
PFont f;
int m=0;
float angle = 0.0;
int i = 0;

void setup()
{
  context = new SimpleOpenNI(this);
  context.enableDepth();
  context.enableRGB();

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }    

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  smooth();
  size(640, 480);
  background (255);
  f = createFont("Futura BT", 16, true); 

  // enable OSC 
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  oscP5.plug(this, "Start", "/start");
  oscP5.plug(this, "Print", "/print");
}

// OSC actions
public void Start(float A) {
  background(255);
  m=0;
}
public void Print(float B) {
  saveFrame("cross-######.jpg");
  m = 1;
}

void draw() {  
  // update the cam
  context.update();

  context.setMirror(false);
  //  // draw depthImageMap
  // image(context.depthImage(),0,0);


  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0;i<userList.length;i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
      drawSkeleton(userList[i]);
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{


  PVector jointPosLhand = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPosLhand);      
  PVector jointPosRhand = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPosRhand);


  // convert real world point to projective space      
  PVector jointPosLhand_Proj = new PVector(); 
  context.convertRealWorldToProjective(jointPosLhand, jointPosLhand_Proj);      
  PVector jointPosRhand_Proj = new PVector(); 
  context.convertRealWorldToProjective(jointPosRhand, jointPosRhand_Proj);     

  //  depth scaling if needed
  //  float lhandScalar = (525/jointPosLhand_Proj.z);      
  //  float rhandScalar = (525/jointPosRhand_Proj.z);

  // receiving OSC commands
  if (m==0) {
    aiflowers(jointPosLhand_Proj.x, jointPosLhand_Proj.y);
    aiflowers(jointPosRhand_Proj.x, jointPosRhand_Proj.y);
  }
  if (m==1) {
    background(255);
    textFont(f, 25);
    fill(214, 0, 0);
    textAlign(CENTER);
    text("#aiflowers @ Instagram", 640/2, 480/2);
    textFont(f, 15);
    text("push START to make aiflowers!", 640/2, 480/2+50);
  }
}

//aiflowers
void aiflowers(float x, float y) {
  pushMatrix();
  translate(x, y);
  scale(sin((angle) + 0.1));
  angle += 0.02;

  fill(224, 227, 32);
  ellipse(0, 0, 27, 27);

  i = i + 10;
  if (i>20) { 
    fill(61, 83, 164);
  }
  if (i>40) { 
    fill(117, 192, 67);
  }
  if (i>60) {  
    fill(236, 34, 38);
  }
  if (i>80) {  
    fill(240, 106, 34);
  }
  if (i>100) {  
    fill(215, 21, 141);
  } 
  if (i>120) {  
    fill(52, 173, 132);   
    i=0;
  } 


  ellipse(0, -27, 27, 27);
  ellipse(0, +27, 27, 27);  
  ellipse(-22, -27/2, 27, 27);  
  ellipse(-22, +27/2, 27, 27);  
  ellipse(+22, -27/2, 27, 27);  
  ellipse(+22, +27/2, 27, 27);
  popMatrix();
}




// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalib)
    context.requestCalibrationSkeleton(userId, true);
  else    
    context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}



