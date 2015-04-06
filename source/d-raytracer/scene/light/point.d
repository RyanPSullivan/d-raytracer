module scene.light.point;

import math.vector;
import colour;

struct PointLight(T)
{
  this(Vector!T position, 
       Colour intensity  )  {
    this.position = position;
    this.intensity = intensity;
  }

  Vector!T position;
  Colour intensity;

}
