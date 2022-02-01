//Mark Ewert - Science One 2021/2022

import java.util.*;
PImage map;
color red = #f78d77;
color blue = #9eaefc;

void setup() {
  //initial setup
  size(1280, 720);
  colorMode(HSB);
  map = loadImage("Switch Test.jpg");
  map.loadPixels();


  //specific test
  color[][] pixelMap = arrayConvert(map.pixels); //index[#y down][#x right]
  //print2DArray(pixelMap);

  //create four PVectors to store coordinate pairs
  PVector redTR = new PVector(0, map.height);
  PVector redBL = new PVector(map.width, 0);
  PVector blueTR = new PVector(0, map.height);
  PVector blueBL = new PVector(map.width, 0);

  //for-loop at the ready
  for (int r = 1; r < pixelMap.length-1; r++) {
    for (int c = 1; c < pixelMap[0].length-1; c++) {
      //creates variables to use 
      color[][] minimap = minimapExtract(pixelMap, r, c);
      String thisPixel = pixelCheckPin(minimap);
      String col = cMatch(minimap[1][1], red) ? "red" : cMatch(minimap[1][1], blue) ? "blue" : "misc";
      PVector check = new PVector(c, r);

      //prints information to console and assigns coordinate information to PVectors
      if (thisPixel.equals("top-right")) {
        //println("FOUND! " + col + " top right @ (" + c + ", " + r + ")");
        if (col.equals("red") && check.x > redTR.x && check.y < redTR.y) redTR.set(check.x, check.y);
        if (col.equals("blue") && check.x > blueTR.x && check.y < blueTR.y) blueTR.set(check.x, check.y);
      } else if (thisPixel.equals("bottom-left")) {
        //println("FOUND! " + col + " bottom left @ (" + c + ", " + r + ")");
        if (col.equals("red") && check.x < redBL.x && check.y > redBL.y) redBL.set(check.x, check.y);
        if (col.equals("blue") && check.x < blueBL.x && check.y > blueBL.y) blueBL.set(check.x, check.y);
      }
    }
  }

  printCoordinate("Red top right", redTR);
  printCoordinate("Red bottom left", redBL);
  printCoordinate("Blue top right", blueTR);
  printCoordinate("Blue bottom left", blueBL);
  printData(distanceData(redTR, redBL, blueTR, blueBL));

  image(printPinRects(pixelMap, redTR, redBL, blueTR, blueBL), 0, 0);
}//setup -------------------------------------------------------------------------------------------------

color[][] arrayConvert(color[] flatMap) {
  int w = map.width;
  int h = map.height;

  color[][] squareMap = new color[h][w];
  int r = -1;
  for (int c = 0; c < flatMap.length; c++) {
    if (c % w == 0) r++;
    squareMap[r][c-w*r] = flatMap[c];
  }
  return squareMap;
}//arrayConvert -------------------------------------------------------------------------------------------------

color[][] minimapExtract(color[][] bigMap, int centerRow, int centerCol) {
  //check for edge cases
  if (centerRow == 0 || centerRow == bigMap.length-1 || centerCol == 0 || centerCol == bigMap[0].length) {
    print("error! center @(" + centerRow + ", " + centerCol + ")");
    return new color[3][3];
  }

  return new color[][]{
    {bigMap[centerRow-1][centerCol-1], bigMap[centerRow-1][centerCol], bigMap[centerRow-1][centerCol+1]}, 
    {bigMap[centerRow][centerCol-1], bigMap[centerRow][centerCol], bigMap[centerRow][centerCol+1]}, 
    {bigMap[centerRow+1][centerCol-1], bigMap[centerRow+1][centerCol], bigMap[centerRow+1][centerCol+1]}
  };
}//3x3Extract -------------------------------------------------------------------------------------------------

String pixelCheckPin(color[][] minimap) {
  //error checking
  if (!(minimap.length == 3 && minimap[0].length == 3)) return "use a 3x3 2D color array";
  color colorToUse = cMatch(minimap[1][1], red) ? red : cMatch(minimap[1][1], blue) ? blue : #000000;
  if (colorToUse == #000000) return "not red or blue";
  String output = "";

  //creates 2D boolean array from minimap data
  boolean[][] colorSurroundings = new boolean[3][3];
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      colorSurroundings[r][c] = cMatch(colorToUse, minimap[r][c]);
    }
  }

  //creates both pre-known boolean 2D arrays to compare
  boolean[][] topRightCheck = {{true, false, false}, {true, true, false}, {true, true, true}};
  boolean[][] botLeftCheck  = {{true, true, true}, {false, true, true}, {false, false, true}};

  if (Arrays.deepEquals(colorSurroundings, topRightCheck)) output = "top-right";
  else if (Arrays.deepEquals(colorSurroundings, botLeftCheck)) output = "bottom-left";
  else output = "idk";

  return output;
}//pixelCheckPin -------------------------------------------------------------------------------------------------

boolean cMatch(color reference, color toCompare) {
  //basic match for initial testing
  //return hex(reference).equals(hex(toCompare));

  //advanced match for map images
  boolean withinHue = abs(hue(reference) - hue(toCompare)) < 20 || abs(hue(reference) - hue(toCompare)) > 240;
  boolean withinSat = abs(saturation(reference) - saturation(toCompare)) < 70;
  boolean withinBri = abs(brightness(reference) - brightness(toCompare)) < 40;
  return withinHue && withinSat && withinBri;
}//cMatch -------------------------------------------------------------------------------------------------

float[] distanceData(PVector redTR, PVector redBL, PVector blueTR, PVector blueBL) {
  //red should be above and to right of blue
  float[] distanceDataArray = new float[4]; //[0] = min distance, [1] = max distance

  //add min
  float min = sqrt(pow(redBL.x-blueTR.x, 2) + pow(redBL.y-blueTR.y, 2));
  distanceDataArray[0] = min;

  //add max
  float max = sqrt(pow(redTR.x-blueBL.x, 2) + pow(redTR.y-blueBL.y, 2));
  distanceDataArray[1] = max;

  //error check min and max
  /*println("redMinCoordinates: x = " + redBottomLeft.x + ", y = " + redBottomLeft.y);
   println("blueMinCoordinates: x = " + blueTopRight.x + ", y = " + blueTopRight.y);
   println("redMaxCoordinates: x = " + redTopRight.x + ", y = " + redTopRight.y);
   println("blueMaxCoordinates: x = " + blueBottomLeft.x + ", y = " + blueBottomLeft.y);*/

  //calculate and add average
  float average = (max + min)/2.0;
  distanceDataArray[2] = average;

  //calculate and add error
  float error = (max - average);
  distanceDataArray[3] = error;

  //return final array with indecies {min, max, average, error}
  return distanceDataArray;
}//DistanceData -------------------------------------------------------------------------------------------------

void print2DArray(color[][] arr) {
  String text = "";
  for (color[] r : arr) {
    for (color c : r) {
      //switch between red and blue
      text += (cMatch(blue, c) ? "0" : ".") + " ";
    }
    text += "\n";
  }
  print(text);
}//print2DArray -------------------------------------------------------------------------------------------------

PImage printPinRects(color[][] pixelMap, PVector redTR, PVector redBL, PVector blueTR, PVector blueBL) {
  PImage algoView = createImage(map.width, map.height, HSB);
  algoView.loadPixels();
  for (int r = 0; r < pixelMap.length; r++) {
    for (int c = 0; c < pixelMap[0].length; c++) {
      color currentPixelColor = pixelMap[r][c];
      currentPixelColor = color(hue(currentPixelColor), saturation(currentPixelColor)/2, brightness(currentPixelColor)/10);
      if (redBL.x <= c && c <= redTR.x && redTR.y <= r && r <= redBL.y) currentPixelColor = red;
      if (blueBL.x <= c && c <= blueTR.x && blueTR.y <= r && r <= blueBL.y) currentPixelColor = blue;
      algoView.pixels[r*pixelMap[0].length+c] = currentPixelColor;
    }
  }
  return algoView;
}//printPinRects -------------------------------------------------------------------------------------------------

void printColorInfo(color c, String mode) {
  float h = hue(c);
  float s = saturation(c);
  float b = brightness(c);
  String hex = hex(c).substring(2, 8);

  if (mode.equals("normal")) {
    h = pRound(h, 1);
    s = pRound(s, 1);
    b = pRound(b, 1);
  } else if (mode.equals("gimp")) {
    h = pRound(h*(360/255.0), 1);
    s = pRound(s*(100/255.0), 1);
    b = pRound(b*(100/255.0), 1);
  } else {
    println("Invalid mode! Use \"normal\" or \"gimp\"");
    return;
  }

  println("hue: " + h + " sat: " + s + " bri: " + b + " hex: " + hex);
}//printColorInfo -------------------------------------------------------------------------------------------------

void printCoordinate(String text, PVector vec) {
  int x = (int)vec.x;
  int y = (int)vec.y;
  println(text + " @ (" + x + ", " + y + ")");
}//printColorInfo -------------------------------------------------------------------------------------------------

void printData(float[] data) {
  //data = {min, max, average, uncertainty)
  println("min distance = " + pRound(data[0], 2) + "px");
  println("max distance = " + pRound(data[1], 2) + "px");
  println("avg distance = " + pRound(data[2], 2) + "px");
  println("u[distance]  = " + pRound(data[3], 2) + "px");
}//printData -------------------------------------------------------------------------------------------------

float pRound(float value, int precision) {
  int scale = (int) Math.pow(10, precision);
  return (float) Math.round(value * scale) / scale;
}//pRound-------------------------------------------------------------------------------------------------

String pixelCheckTest(color[][] minimap) {
  //error checking
  if (!(minimap.length == 3 && minimap[0].length == 3)) return "use a 3x3 2D color array";

  //gets pixel colours surrounding center
  color center = minimap[1][1];
  color left   = minimap[1][0];
  color right  = minimap[1][2];
  color top    = minimap[0][1];
  color bottom = minimap[2][1];

  //checks if pixel is of interest
  if (cMatch(center, #000000)) {
    return "not of interest";
  }

  //fully surrounded
  if (cMatch(center, left) && cMatch(center, right) && cMatch(center, top) && cMatch(center, bottom)) {
    return "inside";
  }

  //creates variable to record determined type of pixel
  String output = "";

  //edges and corners
  if (cMatch(center, left)) {
    if (cMatch(center, top)) {
      output = cMatch(center, bottom) ? "right-side" : "bottom-right";
    } else {
      output = cMatch(center, bottom) ? "top-right" : "impossible";
    }
  } else if (cMatch(center, right)) {
    if (cMatch(center, top)) {
      output = cMatch(center, bottom) ? "left-side" : "bottom-left";
    } else {
      output = cMatch(center, bottom) ? "top-left" : "impossible";
    }
  }
  if (cMatch(center, left) && cMatch(center, right)) {//not left and not right
    if (cMatch(center, top)) output = "bottom-side";
    else if (cMatch(center, bottom)) output = "top-side";
    else output = "impossible-middle";
  }

  return output;
}//pixelCheck -------------------------------------------------------------------------------------------------
