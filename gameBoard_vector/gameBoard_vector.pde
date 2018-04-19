color redLine = color(255, 0, 0, 255);
color yellowLine = color(255, 255, 0, 255);
color greenLine = color(0, 255, 0, 255);
color[] colors = {redLine, yellowLine, greenLine};
boolean downFlag = true;
ArrayList<Neighborhood> playSpace = new ArrayList<Neighborhood>();
ArrayList<Citizen> population = new ArrayList<Citizen>();

int rowLength = 6; // set # rows/columns (board is always square)
int populationSize = 1; // set number of citizens
int cSize = 12; // citizen render circle radius
float maxVelocity = 1.5;
float friction = 0.05;

void setup(){
  size(800, 800);
  //fullScreen();
  for (int j = 0; j < rowLength; j++){
    for (int i = 0; i < rowLength; i++){
      playSpace.add(new Neighborhood());
      playSpace.get(j*rowLength+i).colorVal = int(random(3));
      playSpace.get(j*rowLength+i).x = i;
      playSpace.get(j*rowLength+i).y = j;
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
  }
}

void draw(){
  population.get(0).evaluateCity();
  int size = height / rowLength;
  background(0);
  for (int i = 0; i < sq(rowLength); i++){
    noStroke();
    fill(colors[int(playSpace.get(i).colorVal)]);
    rect(playSpace.get(i).x * size, playSpace.get(i).y * size, size, size);
    playSpace.get(i).displayValue(population.get(0));
  }
  for (int i = 0; i < population.size(); i++){ //check each citizen for collisions with other citizens
    noStroke();
    if (population.get(i).citizenColor == 0){
      fill(#000000);
    } else {fill(#ffffff);}
    ellipse(population.get(i).position.x, population.get(i).position.y, cSize, cSize);
    population.get(i).move();
  }
}

class Neighborhood {
  int colorVal;
  int x, y; // coordinate address (grid coordinate, not pixel)
  void print(){
    println(x, ", ", y);
  }
  
  //display a Neighborhood's value from the perspective of a given Citizen
  void displayValue(Citizen agent){
    int size = height/rowLength;
    fill(0);
    textAlign(CENTER);
    text(agent.neighborhoodValues[x+(rowLength*y)], x*size + size/2, (y+1)*size-size/2);
  }
}

class Citizen {
  PVector position, velocity, acceleration;
  int addressX, addressY, lastX, lastY, addressColor;
  boolean moveFlag = false;
  int citizenColor = int(random(1));
  float r, m;
  float[] neighborhoodValues = new float[playSpace.size()];
  float currentVal, maxVal;
  Citizen(float x, float y, float xv, float yv, float xa, float ya){
    position = new PVector(x, y);
    velocity = new PVector(xv, yv);
    acceleration = new PVector(xa, ya);
    r = cSize;
    m = r * .1;
  }
  
  void evaluateCity(){
    int size = height/rowLength;
    //assign a value based on color code and population
    for (int i = 0; i < sq(rowLength); i++){
      if (playSpace.get(i).colorVal == 2){
        neighborhoodValues[i] = 2.0;
      }
      else if (playSpace.get(i).colorVal == 1){
        neighborhoodValues[i] = 0.0;
      }
      else if (playSpace.get(i).colorVal == 0){
        neighborhoodValues[i] = -2.0;
      }
      /* switch (playSpace.get(i).population){
        case 0:
            neighborhoodValues[i] += 0.2;
        case 1: 
            neighborhoodValues[i] += 0.3;
        case 2:
            neighborhoodValues[i] += 0.3;
        case 3: 
            neighborhoodValues[i] += 0.3;
        case 4:
            neighborhoodValues[i] += 0.2;
        case 5: 
            neighborhoodValues[i] += 0;
        case 6:
            neighborhoodValues[i] -= 0.2;
        case 7: 
            neighborhoodValues[i] -= 0.4;
        case 8:
            neighborhoodValues[i] -= 0.8;
        case 9: 
            neighborhoodValues[i] -= 1.8;
        default:
            neighborhoodValues[i] -= 4.0;
      } */
      
      ArrayList<Neighborhood> adjacents = getAdjacent(playSpace.get(i).x, playSpace.get(i).y);
      for (int j = 0; j < adjacents.size(); j++){
        if (adjacents.get(j).colorVal == 2){ 
          neighborhoodValues[i] += 0.25;}
        else if (adjacents.get(j).colorVal == 0){
          neighborhoodValues[i] -= 0.25;
        }
      }
      
     // check to see if Citizen has moved to a new space
     getAddress();
     if (lastX != addressX || lastY != addressY){ 
       lastX = addressX;
       lastY = addressY;
       for (int k = 0; k < sq(rowLength); k++){
         if (position.x > playSpace.get(k).x * size && position.x < playSpace.get(k).x * size + size && position.y > playSpace.get(k).y * size && position.y < playSpace.get(k).y * size + size){
           //neighborhoodValues[i] += 0.5;
           println("space change");
         }
      }
     }
    }
  }
  
  void getAddress(){
    int size = height / rowLength;
    for (int i = 0; i < sq(rowLength); i++){
      if (position.x > playSpace.get(i).x * size && position.x < playSpace.get(i).x * size + size && position.y > playSpace.get(i).y * size && position.y < playSpace.get(i).y * size + size){
        addressX = playSpace.get(i).x;
        addressY = playSpace.get(i).y;
        addressColor = playSpace.get(i).colorVal;
        currentVal = neighborhoodValues[i];
      }
    } 
  }
  
  void move(){
    //move toward the best Neighborhood on the board
    ArrayList<Neighborhood> moveOptions = playSpace; //set entire board as move option
    int size = height / rowLength;
    Neighborhood destination = new Neighborhood();

    for (int i = 0; i < moveOptions.size(); i++){ // find the best of possibilities; set as destination
       if (maxVal <= neighborhoodValues[i]){
         maxVal = neighborhoodValues[i];
         
         destination.x = moveOptions.get(i).x;
         destination.y = moveOptions.get(i).y;
         print("best score: " + maxVal + " location: ");
         destination.print();
         println("current score: " + currentVal + " location: " + addressX + ", " + addressY);
       }
    }
    // Apply global friction
    if (velocity.x > 0){
      velocity.x -= friction;
    }
    if (velocity.x < 0){
      velocity.x += friction;
    }
    if (velocity.y > 0){
      velocity.y -= friction;
    }
    if (velocity.y < 0){
      velocity.y += friction;
    }
    
  // accelerate toward best destination 
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
    // cap the total velocity
    if (velocity.x > maxVelocity){ 
      velocity.x = maxVelocity;
    }
    if (velocity.x < maxVelocity * -1){
      velocity.x = maxVelocity * -1;
    }
    if (velocity.y > maxVelocity){
      velocity.y = maxVelocity;
    }
    if (velocity.y < maxVelocity * -1){
      velocity.y = maxVelocity * -1;
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

void mousePressed(){
  population.get(0).evaluateCity();
  downFlag = true;
  int size = height / rowLength;
  for (int i = 0; i < sq(rowLength); i++){
    if (mouseX > playSpace.get(i).x * size && mouseX < playSpace.get(i).x * size + size && mouseY > playSpace.get(i).y * size && mouseY < playSpace.get(i).y * size + size){
      println(playSpace.get(i).x, playSpace.get(i).y);
      if (mouseButton == LEFT) {
        playSpace.get(i).colorVal = colorShiftDown(playSpace.get(i).colorVal);
      } else if (mouseButton == RIGHT) {
        playSpace.get(i).colorVal = colorShiftUp(playSpace.get(i).colorVal);
      }
      //getAdjacent(playSpace.get(i).x, playSpace.get(i).y);
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

ArrayList<Neighborhood> getAdjacent(int x, int y){
  ArrayList<Neighborhood> adjacents = new ArrayList<Neighborhood>();
  //println("this address: ", x, ", ", y);
  for (int i = 0; i < sq(rowLength); i++){
    if ((playSpace.get(i).x <= x + 1 && playSpace.get(i).x >= x - 1 && playSpace.get(i).y <= y + 1 && playSpace.get(i).y >= y - 1)){ 
      adjacents.add(playSpace.get(i));
    }
    
    //remove the space under consideration from the list of adjacents
    if (playSpace.get(i).x == x && playSpace.get(i).y == y){ 
      adjacents.remove(playSpace.get(i));
    }
  }
  return adjacents;
}
  
