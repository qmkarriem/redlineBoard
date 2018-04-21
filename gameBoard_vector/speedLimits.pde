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
