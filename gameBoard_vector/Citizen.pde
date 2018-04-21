class Citizen {
  PVector position, velocity, acceleration;
  Neighborhood destination;
  int addressX, addressY, lastX, lastY, addressColor;
  int size = height/rowLength;
  boolean moveFlag = false;
  int citizenColor = int(random(1));
  float holcDifferential = 1.0;  //higher values make Citizens more sensitive to color value
  float crowdingTolerance = 5.0;  //higher values make Citizens more willing to settle in populated areas
  float distanceTolerance = 8.0; //higher values make Citizens more willing to travel
  float r, m;
  float[] neighborhoodValues = new float[city.size()];
  float currentVal, maxVal;
  Citizen(float x, float y, float xv, float yv, float xa, float ya){
    position = new PVector(x, y);
    velocity = new PVector(xv, yv);
    acceleration = new PVector(xa, ya);
    r = cSize;
    m = r * .1;
  }
  
  //set values for every Neighborhood from the perspective of this Citizen
  void evaluateCity(){
    //assign a value based on color code
    for (int i = 0; i < sq(rowLength); i++){
        neighborhoodValues[i] = calculateValue(this, city.get(i));
    } 
  }
  
  // check to see if Citizen has moved to a new Neighborhood 
  void updateCity(){
    getAddress();
    if (lastX != addressX || lastY != addressY){ 
      evaluateCity();
      lastX = addressX;
      lastY = addressY;
     }
     setDestination();
   }
  
  //get the address of the Neighborhood the Citizen occupies
  void getAddress(){
    for (int i = 0; i < sq(rowLength); i++){
      if (position.x > city.get(i).x * size && position.x < city.get(i).x * size + size && position.y > city.get(i).y * size && position.y < city.get(i).y * size + size){
        addressX = city.get(i).x;
        addressY = city.get(i).y;
        addressColor = city.get(i).colorVal;
        city.get(i).popCount += 1;
        //println(city.get(i).popCount);
        currentVal = neighborhoodValues[i];
      }
    } 
  }
  
  // find the best possibility and set it as destination
  void setDestination(){
    ArrayList<Neighborhood> moveOptions = city; //set entire board as move option
    for (int i = 0; i < moveOptions.size(); i++){ 
       if (maxVal < neighborhoodValues[i]){
         maxVal = neighborhoodValues[i];
         destination = moveOptions.get(i);
         //println("destination set to (" + destination.x + ", " + destination.y + "), valued at " + neighborhoodValues[i] + ", " + distance(addressX, addressY, destination.x, destination.y) + " away");
       }
    }
  }
}
