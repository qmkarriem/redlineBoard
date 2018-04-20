color redLine = color(255, 0, 0, 255);
color yellowLine = color(255, 255, 0, 255);
color greenLine = color(0, 255, 0, 255);
color[] colors = {redLine, yellowLine, greenLine};
boolean downFlag = true;
ArrayList<Neighborhood> city = new ArrayList<Neighborhood>();
ArrayList<Citizen> population = new ArrayList<Citizen>();

int rowLength = 8; // set # rows/columns (board is always square)
int populationSize = 1; // set number of citizens
int cSize = 12; // citizen render circle radius
float maxVelocity = 1.5;
float friction = 0.05;

void setup(){
  size(800, 800);
  //fullScreen();
  for (int j = 0; j < rowLength; j++){
    for (int i = 0; i < rowLength; i++){
      city.add(new Neighborhood());
      city.get(j*rowLength+i).colorVal = int(random(3));
      city.get(j*rowLength+i).x = i;
      city.get(j*rowLength+i).y = j;
    }
  }
  for (int i = 0; i < populationSize; i++){ // make the citizens
    population.add(new Citizen(random(width - (cSize + 1)) + cSize + 1, random(height - (cSize + 1)) + cSize + 1, random(0.1), random(0.1), 0.15, 0.15));
    //move a citizen if it overlaps with another citizen (Just once? What if the new placement overlaps with a different agent?)
    for (int j = 0; j < population.size(); j++){
        if (j != i){
          PVector bVect = PVector.sub(population.get(i).position, population.get(j).position);
          float bVectMag = bVect.mag();
          if (bVectMag < cSize){
            population.get(i).position.x = random(width - (cSize + 1)) + cSize + 1;
            population.get(i).position.y = random(height - (cSize + 1)) + cSize + 1;
          }
        }
    }
    population.get(i).evaluateCity();
  }
  
}

void draw(){
  int size = height / rowLength;
  background(0);
  for (int i = 0; i < sq(rowLength); i++){
    noStroke();
    fill(colors[int(city.get(i).colorVal)]);
    rect(city.get(i).x * size, city.get(i).y * size, size, size);
    city.get(i).displayValue(population.get(0));
  }
  for (int i = 0; i < population.size(); i++){ //check each citizen for collisions with other citizens
    noStroke();
    if (population.get(i).citizenColor == 0){
      fill(#000000);
    } else {fill(#ffffff);}
    ellipse(population.get(i).position.x, population.get(i).position.y, cSize, cSize);
    population.get(i).updateCity();
    speedLimits(population.get(i));
    population.get(i).move();
  }
}

class Neighborhood {
  int colorVal;
  int size = height/rowLength;
  int x, y; // coordinate address (grid coordinate, not pixel)
  void print(){
    println(x, ", ", y);
  }
  
  //display a Neighborhood's value from the perspective of a given Citizen
  void displayValue(Citizen agent){
    fill(0);
    textAlign(CENTER);
    text(agent.neighborhoodValues[x+(rowLength*y)], x*size + size/2, (y+1)*size-size/2);
  }
}

class Citizen {
  PVector position, velocity, acceleration;
  Neighborhood destination;
  int addressX, addressY, lastX, lastY, addressColor;
  int size = height/rowLength;
  boolean moveFlag = false;
  int citizenColor = int(random(1));
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
    //assign a value based on color code and population
    for (int i = 0; i < sq(rowLength); i++){
      if (city.get(i).colorVal == 2){
        neighborhoodValues[i] = 2.0;
      }
      else if (city.get(i).colorVal == 1){
        neighborhoodValues[i] = 0.0;
      }
      else if (city.get(i).colorVal == 0){
        neighborhoodValues[i] = -2.0;
      }
      neighborhoodValues[i] -= (distance(addressX, addressY, city.get(i).x, city.get(i).y)/12);

      ArrayList<Neighborhood> adjacents = getAdjacent(city.get(i).x, city.get(i).y);
      for (int j = 0; j < adjacents.size(); j++){
        if (adjacents.get(j).colorVal == 2){ 
          neighborhoodValues[i] += 0.25;}
        else if (adjacents.get(j).colorVal == 0){
          neighborhoodValues[i] -= 0.25;
        }
      }
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
         println("destination set to (" + destination.x + ", " + destination.y + "), valued at " + neighborhoodValues[i] + ", " + distance(addressX, addressY, destination.x, destination.y) + " away");
       }
    }
  }
  
  //accelerate toward a "destination" Neighborhood
  void move(){
    if (position.x < (destination.x * size) + size/2){ 
      velocity.x += acceleration.x;
    }
    if (position.x > (destination.x * size) + size/2){
      velocity.x -= acceleration.x;
    }
    if (position.y < ((destination.y) * size) + size/2){
      velocity.y += acceleration.y;
    }
    if (position.y > ((destination.y) * size) + size/2){
      velocity.y -= acceleration.y;
    }   
    position.add(velocity);
  }
 
  boolean checkCollision(Citizen other){
    PVector bVect = PVector.sub(other.position, position);
    float bVectMag = bVect.mag();
    float collisionIntensity = 2.0;
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
      bTemp[0].x += vFinal[0].x * collisionIntensity/2;
      bTemp[1].x += vFinal[1].x * collisionIntensity/2;

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
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      return true;
    } else {
      return false;
    }
  }
}

//change Neighborhood values via mouse clicks & update Citizen evaluations of Neighborhoods
void mousePressed(){
  downFlag = true;
  int size = height / rowLength;
  for (int i = 0; i < sq(rowLength); i++){
    if (mouseX > city.get(i).x * size && mouseX < city.get(i).x * size + size && mouseY > city.get(i).y * size && mouseY < city.get(i).y * size + size){
      println(city.get(i).x, city.get(i).y);
      if (mouseButton == LEFT) {
        city.get(i).colorVal = colorShiftDown(city.get(i).colorVal);
      } else if (mouseButton == RIGHT) {
        city.get(i).colorVal = colorShiftUp(city.get(i).colorVal);
      }
      //getAdjacent(city.get(i).x, city.get(i).y);
    }
  }
  for (int i = 0; i < population.size(); i++){
    population.get(i).maxVal = population.get(i).currentVal;
    population.get(i).evaluateCity();
    population.get(i).updateCity();
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

//return a list of Neighborhoods that surround any given address
ArrayList<Neighborhood> getAdjacent(int x, int y){
  ArrayList<Neighborhood> adjacents = new ArrayList<Neighborhood>();
  //println("this address: ", x, ", ", y);
  for (int i = 0; i < sq(rowLength); i++){
    if ((city.get(i).x <= x + 1 && city.get(i).x >= x - 1 && city.get(i).y <= y + 1 && city.get(i).y >= y - 1)){ 
      adjacents.add(city.get(i));
    }
    
    //remove the space under consideration from the list of adjacents
    if (city.get(i).x == x && city.get(i).y == y){ 
      adjacents.remove(city.get(i));
    }
  }
  return adjacents;
}

//return the distance between two x/y coordinate pairs
float distance(int x1, int y1, int x2, int y2){
  return sqrt(sq(x2 - x1) + sq(y2 - y1));
}

//enforce friction on a Citizen and limit its total velocity
void speedLimits(Citizen agent){
  // Apply global friction
  if (agent.velocity.x > 0){
    agent.velocity.x -= friction;
  }
  if (agent.velocity.x < 0){
    agent.velocity.x += friction;
  }
  if (agent.velocity.y > 0){
    agent.velocity.y -= friction;
  }
  if (agent.velocity.y < 0){
    agent.velocity.y += friction;
  }
  // cap the total velocity
  if (agent.velocity.x > maxVelocity){ 
    agent.velocity.x = maxVelocity;
  }
  if (agent.velocity.x < maxVelocity * -1){
    agent.velocity.x = maxVelocity * -1;
  }
  if (agent.velocity.y > maxVelocity){
    agent.velocity.y = maxVelocity;
  }
  if (agent.velocity.y < maxVelocity * -1){
    agent.velocity.y = maxVelocity * -1;
  }
}
