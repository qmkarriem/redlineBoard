float calculateValue(Citizen subjectAgent, Neighborhood objectZone){
  ArrayList<Neighborhood> adjacents = getAdjacent(objectZone.x, objectZone.y);
  float value = 0.0;
  //assign a value based on color code
  if (objectZone.colorVal == 2){
    value = subjectAgent.holcDifferential;
  }
  else if (objectZone.colorVal == 0){
    value = -subjectAgent.holcDifferential;
  }
      
  //adjust the value of a Neighborhood based on population
  value -= float(objectZone.popCount)/subjectAgent.crowdingTolerance;
      
  //reduce the value of distant neighborhoods
  value -= (distance(subjectAgent.addressX, subjectAgent.addressY, objectZone.x, objectZone.y) / subjectAgent.distanceTolerance); 

  //adjust the value of neighborhoods based on surrounding color codes and population
  for (int i = 0; i < adjacents.size(); i++){
    if (adjacents.get(i).colorVal == 2){ 
      value += (subjectAgent.holcDifferential/10);
    }
    else if (adjacents.get(i).colorVal == 0){
      value -= (subjectAgent.holcDifferential/10);
    }
    value -= float(adjacents.get(i).popCount)/(subjectAgent.crowdingTolerance * 5.0);
  }
  return value;
}

//search all Neighborhoods for a specific one and return a Citizen's value of that Neighborhood
float getValue(Citizen subjectAgent, Neighborhood objectZone){
  float value = 0.0;
  for (int i = 0; i < city.size(); i++){
    if (city.get(i) == objectZone){
      value = subjectAgent.neighborhoodValues[i];
    }
  }
  return value;
}
