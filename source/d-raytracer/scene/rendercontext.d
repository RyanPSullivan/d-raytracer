module scene.rendercontext;

import scene.camera;
import scene.scene;
import math.vector;
import math.ray;

import colour;

import scene.light.point;

struct RenderContext(T)
{
  this(Scene!T scene, uint width = 640, uint height = 480)
  {
    this.scene = scene;
    this.width = width;
    this.height = height;
    this.imageAspectRatio = width / cast(float)height;
    this.backgroundColor = Colour(0.2, 0.3, 0.5, 0);
  }

  Ray!T calculateRayForPixel(T)( ulong x, ulong y, Camera!T camera)
  {
    import math.matrix;
    
    Matrix!float camToWorld = camera.transform;
	
    auto rayOrigin = camToWorld.multVecMatrix(Vector!float(0,0,0));

    // remap from raster to screen space
    float xx = (2 * ((x + 0.5) * camera.aperture / this.width) - 1)  * camera.angle * this.imageAspectRatio;
    
    float yy = (1 - 2 *((y + 0.5) / this.height))  * camera.angle;
	
    // create the ray direction, looking down the z-axis
    // and transform by the camera-to-world matrix
    auto rayDirection = camToWorld.multDirMatrix(Vector!float(xx, yy, -1));

    return Ray!float( rayOrigin, 
		      Vector!float.normalize(rayDirection), 
		      camera.nearClippingPlane, 
		      camera.farClippingPlane);
	
  }

  Colour generatePixel( float dof )( ulong x, ulong y, Camera!T camera )
  {
    auto originalRay = calculateRayForPixel!float( x,y, camera );
    int depth = 0;

    static if( dof == 0 )
      {
	//import std.conv; import std.stdio;
	//	writeln( to!string( camera ) );
	return scene.trace( originalRay, depth );
      }
    else
      {
	float pixelWidth = (camera.angle * imageAspectRatio) / width;
	float pixelHeight = camera.angle / height;

	auto result = Colour(0,0,0,0);

	//Now here I compute point P in the scene where I want to focus my scene
	auto P = originalRay.origin + dof * originalRay.direction;

	auto samples = 16;

	//Stratified Sampling i.e. Random sampling (with 16 samples) inside each pixel to add DOF
	foreach( i; 0..samples)
	  {
	    import std.random;
	    float rw  = uniform(-1.0f,1.0f);
	    float rh  = uniform(-1.0f,1.0f);
			
	    float dx =  ( rw * 0.3);
	    float dy =  ( rh * 0.3);

	    auto origin = Vector!T(originalRay.origin.x + dx, originalRay.origin.y + dy, originalRay.origin.z, 1);
			
	    auto dir = Vector!T.normalize(P - origin);
			
	    auto ray  = Ray!T(origin, dir, camera.nearClippingPlane, camera.farClippingPlane);
			
	    result = result + scene.trace( ray, depth );
	  }
			
	return result / cast(float)samples; 
      }
  }	

public Colour[][] render( int cameraIndex )
{
  auto camera = scene.cameras[cameraIndex];
  
  import std.parallelism;
  import std.stdio;
  import std.conv;
  
  auto outputBuffer = new Colour[][]( height, width );

  auto count = 0;
  foreach(y, ref row; parallel(outputBuffer))
    {
      foreach(x, ref pixel; parallel(row))
	{
	  pixel = generatePixel!( 0 )( x,y, camera );

	  write("\r" ~to!string(cast(int)(100*count++/cast(float)(width*height))));
	}
    }

  writeln();

  return outputBuffer;
}

  Scene!T scene;

  uint width;
  uint height;

  float imageAspectRatio;
  Colour backgroundColor;
}

