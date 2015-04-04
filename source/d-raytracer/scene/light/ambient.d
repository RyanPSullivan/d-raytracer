module scene.light.ambient;

import colour;

struct AmbientLight
{
  this( Colour colour )
  {
    this.colour = colour;
  }

  public Colour colour;
}
