class Citizen {
  PVector position, velocity, acceleration;
  Neighborhood destination;
  int addressX, addressY, lastX, lastY, addressColor;
  int size = height/rowLength;
  boolean moveFlag = false;
  int citizenColor = int(random(1));
  float holcDifferential = 1.0;  //higher values make Citizens more sensitive to color value
  float crowdingTolerance = 3.0;  //higher values make Citizens more willing to settle in populated areas
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
  
  //accelerate toward a "destination" Neighborhood
  void move(){
    
    //designate alternate "spots" to settle inside an occupied Neighborhood
    float spotX = size/2;
    float spotY = size/2;
    if (destination.popCount == 0){spotX = size/2; spotY = size/2;}
    if (destination.popCount == 1){spotX = size/2; spotY = size/2;}
    if (destination.popCount == 2){spotX = size/4; spotY = size/4;}
    if (destination.popCount == 3){spotX = size*3/4; spotY = size*3/4;}
    if (destination.popCount == 4){spotX = size/4; spotY = size*3/4;}
    if (destination.popCount == 5){spotX = size*3/4; spotY = size/4;}
    
    if (position.x < (destination.x * size) + spotX){ 
      velocity.x += acceleration.x;
    }
    if (position.x > (destination.x * size) + spotX){
      velocity.x -= acceleration.x;
    }
    if (position.y < ((destination.y) * size) + spotY){
      velocity.y += acceleration.y;
    }
    if (position.y > ((destination.y) * size) + spotY){
      velocity.y -= acceleration.y;
    }   
    position.add(velocity);
  }
 
  boolean checkCollision(Citizen other){
    PVector bVect = PVector.sub(other.position, position);
    float bVectMag = bVect.mag();
    float collisionIntensity = 3.5;
    if (bVectMag < cSize){
      // get angle of bVect
      float theta  = bVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

        /* this ball's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
      bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0] // Add a multiplier to determine collision intensity
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m) * collisionIntensity;
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m) * collisionIntensity;
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x * collisionIntensity;
      bTemp[1].x += vFinal[1].x * collisionIntensity;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      float swerve = random(-10, 10);
      other.position.x = position.x + bFinal[1].x + swerve/4;
      other.position.y = position.y + bFinal[1].y + swerve/4;
      position.x -= random(10)/4;
      position.y -= random(10)/4;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y + swerve/2;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x + swerve/2;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y - swerve/2;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x - swerve/2;
      return true;
    } else {
      return false;
    }
  }
}
