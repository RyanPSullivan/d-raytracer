module scene.model.model;

public import scene.model.material;

import math.ray;
import math.matrix;

import scene.model.collision;

class Model(T)
{

  this( Matrix!T transformation, Material material )
  {
    this.material = material;
    this.transformation = transformation;
  }

  abstract bool intersects( Ray!T ray, ref Collision!T collision );

	
  protected Matrix!T transformation;
  public Material material;
}

