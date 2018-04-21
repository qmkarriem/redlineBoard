boolean checkCollision(Citizen subject, Citizen other){
  PVector bVect = PVector.sub(other.position, subject.position);
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

    vTemp[0].x  = cosine * subject.velocity.x + sine * subject.velocity.y;
    vTemp[0].y  = cosine * subject.velocity.y - sine * subject.velocity.x;
    vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
    vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
    PVector[] vFinal = {  
      new PVector(), new PVector()
    };

    // final rotated velocity for b[0] // Add a multiplier to determine collision intensity
    vFinal[0].x = ((subject.m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (subject.m + other.m) * collisionIntensity;
    vFinal[0].y = vTemp[0].y;

    // final rotated velocity for b[0]
    vFinal[1].x = ((other.m - subject.m) * vTemp[1].x + 2 * subject.m * vTemp[0].x) / (subject.m + other.m) * collisionIntensity;
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
    float swerve = random(-6, 6);
    other.position.x = subject.position.x + bFinal[1].x + swerve/4;
    other.position.y = subject.position.y + bFinal[1].y + swerve/4;
    subject.position.x -= swerve/4;
    subject.position.y -= swerve/4;

    subject.position.add(bFinal[0]);

    // update velocities
    subject.velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y + swerve/2;
    subject.velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x + swerve/2;
    other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y - swerve/2;
    other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x - swerve/2;
    return true;
  } else {
    return false;
  }
}
