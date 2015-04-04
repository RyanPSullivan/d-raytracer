module scene.light.point;

import math.vector;
import colour;

struct PointLight(T)
{
  this(Vector!T position, 
       Colour colour = Colour.white, 
       T diffusePower = 1, 
       T specularPower = 1)
  {
    this.position = position;
    this.colour = colour;
    this.diffusePower = diffusePower;
    this.specularPower = specularPower;
  }

  Vector!T position;
  Colour colour;
  T  diffusePower;
  T  specularPower;
}
