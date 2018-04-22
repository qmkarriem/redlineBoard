color redLine = color(255, 0, 0, 255);
color yellowLine = color(255, 255, 0, 255);
color greenLine = color(0, 255, 0, 255);
color[] colors = {redLine, yellowLine, greenLine};
boolean downFlag = true;
ArrayList<Neighborhood> city = new ArrayList<Neighborhood>();
ArrayList<Citizen> population = new ArrayList<Citizen>();
ArrayList<FloatList> affectTable = new ArrayList<FloatList>(); // 2-dimensional array for affect values (unknown length)

int rowLength = 8; // set # rows/columns (board is always square)
int populationSize = 70; // set number of citizens (try values 10 - 100)
int cSize = 10; // citizen render circle radius
float maxVelocity = 1.0;
float friction = 0.1;


void setup(){
  size(800, 800);
  //fullScreen();
  for (int j = 0; j < rowLength; j++){
    for (int i = 0; i < rowLength; i++){
      city.add(new Neighborhood());
      city.get(j*rowLength+i).colorVal = int(random(3)); //random color codes
      //city.get(j*rowLength+i).colorVal = 1; //neutral color codes
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
  for (int i = 0; i < population.size(); i++){ // initialize affectTable (must wait until all Citizens exist)
    affectTable.add(new FloatList());
    for (int j = 0; j < population.size(); j++){
      affectTable.get(i).append(0.0);
    }
  }
}

void draw(){
  int size = height / rowLength;
  background(0);
  for (int i = 0; i < sq(rowLength); i++){
    noStroke();
    fill(colors[int(city.get(i).colorVal)]);
    rect(city.get(i).x * size, city.get(i).y * size, size, size);
  }
  for (int i = 0; i < population.size(); i++){ 
    noStroke();
    if (population.get(i).citizenColor == 0){     
      fill(#000000);
      if (i == 0){fill(#0000FF);} // make the first agent blue for illustrative purposes
    } else {fill(#ffffff);}
    ellipse(population.get(i).position.x, population.get(i).position.y, cSize, cSize);
    
    //check each citizen for collisions with other citizens, reduce affect for each other.
    for (int j = i+1; j < population.size(); j++){
      if (checkCollision(population.get(i), population.get(j)) == true){
        affectTable.get(i).sub(j, 0.1);
        affectTable.get(j).sub(i, 0.1);      
      }
    }
    population.get(i).maxVal = population.get(i).currentVal;
    population.get(i).evaluateCity();
    population.get(i).updateCity();
    speedLimits(population.get(i));
    move(population.get(i));
  }
  for (int i = 0; i < sq(rowLength); i++){
    city.get(i).displayValue(population.get(0)); //display the first agent's valuation of the city
    city.get(i).popCount = 0;
  }
}

//return the distance between two x/y coordinate pairs
float distance(int x1, int y1, int x2, int y2){
  return sqrt(sq(x2 - x1) + sq(y2 - y1));
}
