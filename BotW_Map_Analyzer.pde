//Mark Ewert - Science One 2021/2022

import java.util.*;
PImage map;

void setup() {
  //initial setup
  size(250, 200);
  map = loadImage("test small.png");
  map.loadPixels();
  image(map, 0, 0, 250, 200);
  
  //specific test
  color[][] pixelMap2D = arrayConvert(map.pixels);
  print2DArray(pixelMap2D);
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
      String type = pixelCheck(minimapExtract(pixelMap, row, col));

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

String pixelCheck(color[][] minimap) {
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

boolean cMatch(color one, color two) {
  //basic match for initial testing
  return hex(one).equals(hex(two));
}//cMatch -------------------------------------------------------------------------------------------------

void print2DArray(color[][] arr) {
  String text = "";
  for (color[] r : arr) {
    for (color c : r) {
      text += (!cMatch(c, #000000) ? "0" : ".") + " ";
    }
    text += "\n";
  }
  print(text);
}//print2DArray -------------------------------------------------------------------------------------------------
