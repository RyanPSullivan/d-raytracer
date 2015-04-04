module scene.rendercontext;

import scene.camera;
import scene.scene;
import math.vector;
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

  Ray!T calculateRayForPixel(T)( ulong x, ulong y, Camera camera)
  {
    Matrix!float camToWorld = renderContext.camera.transform;
	
    auto rayOrigin = camToWorld.multVecMatrix(Vector!float(0,0,0));

    // remap from raster to screen space
    float xx = (2 * ((x + 0.5) / this.width) - 1)  * camera.angle * this.imageAspectRatio;
    float yy = (1 - 2 *((y + 0.5) / this.height))  * camera.angle;
	
    // create the ray direction, looking down the z-axis
    // and transform by the camera-to-world matrix
    auto rayDirection = camToWorld.multDirMatrix(Vector!float(xx, yy, -1));

    return Ray!float( rayOrigin, 
		      Vector!float.normalize(rayDirection), 
		      renderContext.camera.nearClippingPlane, 
		      renderContext.camera.farClippingPlane);
	
  }
  
  Scene!T scene;

  uint width;
  uint height;

  float imageAspectRatio;
  Colour backgroundColor;
}

