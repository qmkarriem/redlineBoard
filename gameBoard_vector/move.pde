//accelerate toward a "destination" Neighborhood
void move(Citizen subject){
  int size = height/rowLength;
  //designate alternate "spots" to settle inside an occupied Neighborhood
  float spotX = size/2;
  float spotY = size/2;
  switch (subject.destination.popCount){
    case 2: spotX = size/4; spotY = size/4; break;
    case 3: spotX = size*3/4; spotY = size*3/4; break;
    case 4: spotX = size/4; spotY = size*3/4; break;
    case 5: spotX = size*3/4; spotY = size/4; break;
    default: spotX = size/2; spotY = size/2;
  }
    
  if (subject.position.x < (subject.destination.x * size) + spotX){ 
    subject.velocity.x += subject.acceleration.x;
  }
  if (subject.position.x > (subject.destination.x * size) + spotX){
    subject.velocity.x -= subject.acceleration.x;
  }
  if (subject.position.y < ((subject.destination.y) * size) + spotY){
    subject.velocity.y += subject.acceleration.y;
  }
  if (subject.position.y > ((subject.destination.y) * size) + spotY){
    subject.velocity.y -= subject.acceleration.y;
  }   
  subject.position.add(subject.velocity);
}
