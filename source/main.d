   /* program prints a
   hello world message
   to the console.  */
import std.stdio;
import generators;

int calculateRayDirection( int x, int y )
{
  return 0;
}

bool intersect(int object, int ray)
{
  return true;
}

struct Vector
{
}

struct Object
{
}

struct Collision
{
  Object object;
  Vector location;
  Vector normal;
}

int getClosestCollidingObject(int ray)
{
  auto objects = [1,2,3];
  
  Collision returningCollision;

  auto minDistance = int.max;

  foreach(object; objects)
    {
      auto collision = intersect( object, ray );
      auto distance = distance( eyePosition, collision.location);
      
      if( distance < minDistance )
	{
	  returningCollision = collision;
	  minDistance = distance;
	}
    }

  return returningCollision;
}

struc Pixel
{
  byte[] red;
  byte[] green;
  byte[] blue;
  byte[] alpha;
}


Pixel generatePixel( int x, int y )
{
  auto ray = calculateRayDirection(x,y);
	  
  auto object = getClosestObject(ray);

  //if the ray collided with an object
  if( object != NULL )
    {
      //compute illimunation
    }   
}

void generateBitmap( string path, int imageWidth, int imageHeight )
{
  //write header

  //write bitmap data
  foreach(x; 0..imageWidth)
    {
      foreach(y; 0..imageHeight)
	{
	  auto pixel = generatePixel( x, y );
	}
    }
}

void main()
{
  auto imageWidth = 100;
  auto imageHeight = 100;

  foreach( pixel; generator( &generatePixel, imageWidth, imageHeight)
	   {
	     writeln(pixel);
	   }
  writeln("Hello, World!");
}
