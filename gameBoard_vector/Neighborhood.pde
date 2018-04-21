class Neighborhood {
  int colorVal;
  int popCount;
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
    text(popCount, x*size + size/2, ((y+1)*size-size/2) + 20);
  }
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
