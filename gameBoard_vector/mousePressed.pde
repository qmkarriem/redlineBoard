//change Neighborhood values via mouse clicks & update Citizen evaluations of Neighborhoods
void mousePressed(){
  downFlag = true;
  int size = height / rowLength;
  for (int i = 0; i < sq(rowLength); i++){
    if (mouseX > city.get(i).x * size && mouseX < city.get(i).x * size + size && mouseY > city.get(i).y * size && mouseY < city.get(i).y * size + size){
      println(city.get(i).x, city.get(i).y, city.get(i).census.size(), city.get(i).census);
      if (mouseButton == LEFT) {
        city.get(i).colorVal = colorShiftDown(city.get(i).colorVal);
      } else if (mouseButton == RIGHT) {
        city.get(i).colorVal = colorShiftUp(city.get(i).colorVal);
      }
      //getAdjacent(city.get(i).x, city.get(i).y);
    }
  }
}

int colorShiftDown(int currentColor){
  currentColor--;
  if (currentColor < 0){
    currentColor = 0;
  }
  return currentColor;
}

int colorShiftUp(int currentColor){
  currentColor++;
  if (currentColor > 2){
    currentColor = 2;
  }
  return currentColor;
}
