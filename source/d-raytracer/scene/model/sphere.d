module scene.model.sphere;

import core.math;

import math.matrix;
import math.vector;
import math.ray;

import scene.model.model;
import scene.model.collision;

class Sphere(T) : Model!T
{
  this( Vector!T origin, float radius, Material material )
    {
      auto transform = Matrix!T.identity;
      transform.translation = Vector!T(origin.x, origin.y, origin.z, 1);

      this( transform, radius, material );
    }
  
  this(Matrix!T transform, 
       float radius,
       Material material )
    {
      super(transform, material);
      this.radius = radius;
      this.radiusSquared = radius * radius;
    }

  override bool intersects(Ray!T ray, ref Collision!T collision) 
  {
    auto rayorig = ray.origin;
    auto raydir = ray.direction; 

    auto pos = transformation.translation;
		
    float a = Vector!T.dot(raydir,raydir);

    float b = Vector!T.dot(raydir , (2.0f * (rayorig-pos)));
    float c = Vector!T.dot(pos,pos) + Vector!T.dot(rayorig,rayorig) -2.0f*Vector!T.dot(rayorig,pos) - radiusSquared;
    float D = b*b + (-4.0f)*a*c;
		
    // If ray can not intersect then stop
    if (D < 0)
      return false;
    D=sqrt(D);
		
    // Ray can intersect the sphere, solve the closer hitpoint
    float t = (-0.5f)*(b+D)/a;
    if (t > 0.0f)
      {
	collision.model = this;
	collision.distance=sqrt(a)*t;
	collision.hit=rayorig + t*raydir;
	collision.normal=(collision.hit - pos) /radius;
      }
    else
      return false;

    return true;
  }
	
  private T radius;
  private T radiusSquared;
}



