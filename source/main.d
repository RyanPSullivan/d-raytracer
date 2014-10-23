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
  @property bool isTransparent { return m_Transparent; }

private:

  bool m_Transparent;
}

struct Ray
{
  Vector direction;
}

struct Collision
{
  Object object;
  Vector location;
  Vector normal;
}

Collision getClosestCollision(int ray)
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

struct Colour
{
  Colour( byte r, byte g, byte b, byte a ) : red(r), green(g), blue(b), alpha(a) {}
  static const Colour BlACK = Colour( 0, 0, 0, 0 );

  byte red;
  byte green;
  byte blue;
  byte alpha;
}

struct Light
{
  Vector position;
  float brightness;
}


Vector lightPosition = Vector(0,0,0);

Colour trace(Vector ray, int depth)
{
  auto collision = getClosestCollision( ray );
  
  //no collision occured return a black pixel for now
  if( collision == null )
    {
      return Pixel.BLACK;
    }

  Colour reflectionColour;
  Colour refractionColour;

  //ray collided with an object
  //reflection
  if( collision.object.IsReflective )
    {
      auto reflectionRay = computeReflectionRay( ray, collision.location );

      reflectionColour = trace( reflectionRay, depth + 1 );
    }

  //refraction
  if( collision.object.IsTransparent )
  {
    auto refractiveRay = computeRefractiveRay();
    
    refractionColour = trace( refractiveRay, depth + 1 );
  }
  
  //shadow
  Ray shadowRay;
  shadowRay.direction = lightPosition - collisiton.location;
  bool isShadow = false;
  foreach(object; objects)
    {
      if( intersect( object, shadowRay ) )
	{
	  return Pixel.BLACK;
	}
    }

  return collision.object.colour * light.brightness;
}
Pixel generatePixel( int x, int y )
{
  auto ray = calculateRayDirection(x,y);

  return trace( ray, 0 ); 
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

  //write footer
}

void main()
{
  auto imageWidth = 100;
  auto imageHeight = 100;

  generateBitmap("output.bmp", imageWidth, imageHeight);
  writeln("Hello, World!");
}
