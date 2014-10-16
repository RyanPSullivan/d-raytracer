   /* program prints a
   hello world message
   to the console.  */
import std.stdio;
 
int calculateRayDirection( int x, int y )
{
  return 0;
}

bool intersect(int object, int ray)
{
  return true;
}

int getClosestObject(int ray)
{
  auto objects = [1,2,3];

  foreach(object; objects)
    {
      if(intersect(object, ray))
	{
	  return 1;
	}
    }

  return -1;
}


void main()
{
  auto imageWidth = 100;
  auto imageHeight = 100;

  foreach(x; 0 .. imageWidth)
    {
      foreach(y; 0 .. imageHeight)
	{
	  auto ray = calculateRayDirection(x,y);
	  
	  auto object = getClosestObject(ray);
	}
    }
  writeln("Hello, World!");
}
