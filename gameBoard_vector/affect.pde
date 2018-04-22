//search all Citizens for a specific one and return a given Citizen's affect to it
void generateAffect(){
  
}
float getAffect(Citizen agent, Citizen other){
  float value = 0.0;
  for (int i = 0; i < population.size(); i++){
    if (population.get(i) == agent){
      for (int j = 0; j < population.size(); j++){
        if (population.get(j) == other){
          value = affectTable.get(i).get(j);
        }
      }
    }
  }
  return value;
}
