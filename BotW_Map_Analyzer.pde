//Mark Ewert - Science One 2021/2022

import java.util.*;
PImage map;
color red = #FF0000;
color blue = #5e619a;

void setup() {
  //initial setup
  size(500, 400);
  colorMode(HSB);
  map = loadImage("medium blue pin.png");
  map.loadPixels();
  image(map, 0, 0, width, height);

  //specific test
  color[][] pixelMap = arrayConvert(map.pixels); //index[#y down][#x right]
  print2DArray(pixelMap);

  //for-loop at the ready
  /*for (int r = 1; r < pixelMap.length-1; r++) {
    for (int c = 1; c < pixelMap[0].length-1; c++) {
      String thisPixel = pixelCheckPin(minimapExtract(pixelMap, r, c));
      if (thisPixel.equals("top-right")) {
        println("top right corner @ (" + c + ", " + r + ")");
      } else if (thisPixel.equals("bottom-left")){
        println("bottom left corner @ (" + c + ", " + r + ")");
      }
    }
  }
  println("done");*/
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

double[] distanceData(color[][] pixelMap) {
  //red should be above and to right of blue
  double[] distanceDataArray = new double[4]; //[0] = min distance, [1] = max distance
  PVector redBottomLeft = new PVector();
  PVector blueTopRight = new PVector();
  PVector redTopRight = new PVector();
  PVector blueBottomLeft = new PVector();

  //loops through pixel map
  for (int row = 1; row < pixelMap.length-1; row++) {
    for (int col = 1; col < pixelMap[0].length-1; col++) {
      //current pixel
      color currentColor = pixelMap[row][col];
      String type = pixelCheckPin(minimapExtract(pixelMap, row, col));

      //min
      if (cMatch(currentColor, #FF0000) && type.equals("bottom-left")) redBottomLeft.set(col, row);
      if (cMatch(currentColor, #0000FF) && type.equals("top-right")) blueTopRight.set(col, row);

      //max
      if (cMatch(currentColor, #FF0000) && type.equals("top-right")) redTopRight.set(col, row);
      if (cMatch(currentColor, #0000FF) && type.equals("bottom-left")) blueBottomLeft.set(col, row);
    }
  }
  //add min
  double min = sqrt(pow(redBottomLeft.x-blueTopRight.x, 2) + pow(redBottomLeft.y-blueTopRight.y, 2));
  distanceDataArray[0] = min;

  //add max
  double max = sqrt(pow(redTopRight.x-blueBottomLeft.x, 2) + pow(redTopRight.y-blueBottomLeft.y, 2));
  distanceDataArray[1] = max;

  //error check min and max
  /*println("redMinCoordinates: x = " + redBottomLeft.x + ", y = " + redBottomLeft.y);
   println("blueMinCoordinates: x = " + blueTopRight.x + ", y = " + blueTopRight.y);
   println("redMaxCoordinates: x = " + redTopRight.x + ", y = " + redTopRight.y);
   println("blueMaxCoordinates: x = " + blueBottomLeft.x + ", y = " + blueBottomLeft.y);*/

  //calculate and add average
  double average = (max + min)/2.0;
  distanceDataArray[2] = average;

  //calculate and add error
  double error = (max - average);
  distanceDataArray[3] = error;

  //return final array with indecies {min, max, average, error}
  return distanceDataArray;
}//DistanceData -------------------------------------------------------------------------------------------------

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

String pixelCheckPin(color[][] minimap) {
  //error checking
  if (!(minimap.length == 3 && minimap[0].length == 3)) return "use a 3x3 2D color array";
  String output = "";

  //creates 2D boolean array from minimap data
  boolean[][] redSurroundings = new boolean[3][3];
  boolean[][] blueSurrounding = new boolean[3][3];
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      redSurroundings[r][c] = cMatch(minimap[1][1], minimap[r][c]);
      //blueSurroundings[r][c] = cMatch(
    }
  }

  //creates both pre-known boolean 2D arrays to compare
  boolean[][] topRightCheck = {{true, false, false}, {true, true, false}, {true, true, true}};
  boolean[][] botLeftCheck  = {{true, true, true}, {false, true, true}, {false, false, true}};

  if (Arrays.deepEquals(redSurroundings, topRightCheck)) output = "top-right";
  else if (Arrays.deepEquals(redSurroundings, botLeftCheck)) output = "bottom-left";
  else output = "idk";

  return output;
}//pixelCheckPin -------------------------------------------------------------------------------------------------

boolean cMatch(color reference, color toCompare) {
  //basic match for initial testing
  //return hex(reference).equals(hex(toCompare));

  //advanced match for map images
  boolean withinHue = abs(hue(reference) - hue(toCompare)) < 10 || abs(hue(reference) - hue(toCompare)) > 250;
  boolean withinSat = saturation(toCompare) < 175;
  boolean withinBri = brightness(toCompare) > 225;
  return withinHue && withinSat && withinBri;
}//cMatch -------------------------------------------------------------------------------------------------

void print2DArray(color[][] arr) {
  String text = "";
  for (color[] r : arr) {
    for (color c : r) {
      text += (cMatch(blue, c) ? "0" : ".") + " ";
    }
    text += "\n";
  }
  print(text);
}//print2DArray -------------------------------------------------------------------------------------------------

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

float pRound(float value, int precision) {
  int scale = (int) Math.pow(10, precision);
  return (float) Math.round(value * scale) / scale;
}//pRound-------------------------------------------------------------------------------------------------
