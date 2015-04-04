import std.stdio;
import std.math;
import std.conv;
import std.random;
import std.parallelism;
import std.range;

import math.vector;
import math.matrix;

import scene.scene;

import scene.rendercontext;

import scene.model.collision;
import scene.model.model;
import scene.camera;

import colour;
import math.ray;



Ray!T calculateRayForPixel(T)( ulong x, ulong y, RenderContext!T renderContext)
{
  Matrix!float camToWorld = renderContext.camera.transform;
	
  auto rayOrigin = camToWorld.multVecMatrix(Vector!float(0,0,0));

  // remap from raster to screen space
  float xx = (2 * ((x + 0.5) / renderContext.width) - 1)  * renderContext.camera.angle * renderContext.imageAspectRatio;
  float yy = (1 - 2 *((y + 0.5) / renderContext.height))  * renderContext.camera.angle;
	
  // create the ray direction, looking down the z-axis
  // and transform by the camera-to-world matrix
  auto rayDirection = camToWorld.multDirMatrix(Vector!float(xx, yy, -1));

  return Ray!float( rayOrigin, 
		    Vector!float.normalize(rayDirection), 
		    renderContext.camera.nearClippingPlane, 
		    renderContext.camera.farClippingPlane);
	
}

Collision!T getClosestCollidingModel(T)(Ray!T ray, Model!T[] models){

  auto collision = Collision!T();
  collision.distance = T.max;
  foreach(model; models)
    {
      auto tempCollision = Collision!T();

      if( model.intersects( ray, tempCollision ) )
	{
	  if( tempCollision.distance < collision.distance 
	      && tempCollision.distance > ray.min
	      && tempCollision.distance < ray.max)
	    {
	      collision = tempCollision;
	    }
	}
    }

  return collision;
}


Colour trace(T)(Ray!T ray, int depth, RenderContext!T renderContext)
{
  auto collision = getClosestCollidingModel!T( ray, renderContext.models );
	
  //no co	llision occured return a black pixel for now                                                                                                                                                                      
  if( collision.model is null )
    {
      return renderContext.backgroundColor;
    }
  else
    {
      //return Colour.WHITE;
      //return Colour((collision.normal.x + 1)/2, (collision.normal.y + 1)/2, (collision.normal.z + 1)/2, 0);
		

      T lambertIntensity = 0;
      T specularIntensity = 0;
      Colour lightColour = Colour.white;

      foreach(light; renderContext.pointLights)
	{
	  auto vectorToLight = light.position - collision.hit;
	  auto directionToLight = Vector!T.normalize( vectorToLight );
	  auto directionToCamera = Vector!T.normalize( renderContext.camera.transform.translation - collision.hit );

	  //dont apply this light if its obfuscated
	  auto shadowRay = Ray!T( collision.hit, directionToLight, 0.01, vectorToLight.magnitude() );
	  auto shadowCollision = getClosestCollidingModel( shadowRay, renderContext.models );

	  //the shadow ray didn't reach the light, continue to next light
	  if( shadowCollision.model !is null )
	    {
	      continue;
	    }

	  //diffuse calulation
	  auto lightDot = Vector!T.dot( directionToLight, collision.normal );

	  if( lightDot < 0 ) lightDot = 0;

	  lambertIntensity += lightDot * light.diffusePower;
			
	  //specular calculation
	  auto camToLight = Vector!T.normalize(directionToLight + directionToCamera);
	  auto cameraDot = Vector!T.dot(collision.normal, camToLight);

	  if( cameraDot < 0 ) cameraDot = 0;

	  auto intensity = pow( cameraDot, 100 );

	  specularIntensity += intensity * light.specularPower; 

	  lightColour = lightColour + light.colour;
	}

      auto shadingColour =(collision.model.material.ambient * lightColour * ((Colour(1,1,1,0) * 0f)) +
			   (collision.model.material.diffuse * lambertIntensity) +
			   (collision.model.material.specular* specularIntensity));

		
      if( depth < 2 && 
	  collision.model.material.isReflective )
	{
	  auto kr = collision.model.material.reflectivity;

	  auto reflectionRay = Ray!T(collision.hit,
				     Vector!T.normalize(Vector!T.reflect(ray.direction,collision.normal)),
				     0.01);

	  auto reflectionColour = trace(reflectionRay, depth+1,renderContext);

	  shadingColour = (shadingColour * (1.0f-kr)) + (reflectionColour * kr);
	}

      return shadingColour;
    }
}

Colour generatePixel(T, float dof)( ulong x, ulong y, RenderContext!T renderContext )
{
  auto originalRay = calculateRayForPixel!float(x,y, renderContext );
  int depth = 0;

  static if( dof == 0 )
    {
      return trace!T( originalRay, depth, renderContext );
    }
  else
    {
      float pixelWidth = (renderContext.camera.angle * renderContext.imageAspectRatio) / renderContext.width;
      float pixelHeight = renderContext.camera.angle / renderContext.height;

      Colour result = Colour(0,0,0,0);

      //Now here I compute point P in the scene where I want to focus my scene
      auto P = originalRay.origin + dof * originalRay.direction;

      auto samples = 16;

      //Stratified Sampling i.e. Random sampling (with 16 samples) inside each pixel to add DOF
      foreach( i; 0..samples)
	{
	  float rw  = uniform(-1.0f,1.0f);
	  float rh  = uniform(-1.0f,1.0f);
			
	  float dx =  ( rw * 0.3);
	  float dy =  ( rh * 0.3);

	  auto origin = Vector!T(originalRay.origin.x + dx, originalRay.origin.y + dy, originalRay.origin.z, 1);
			
	  auto dir = Vector!T.normalize(P - origin);
			
	  auto ray  = Ray!T(origin, dir, renderContext.camera.nearClippingPlane, renderContext.camera.farClippingPlane);
			
	  result = result + trace!T( ray, depth, renderContext );
	}
		
		
      return result / cast(float)samples; 
    }
}	

Colour[][] generateImageBuffer(T)( RenderContext!T renderContext )
{
  auto imageWidth = renderContext.width;
  auto imageHeight = renderContext.height;

  auto outputBuffer = new Colour[][](imageHeight, imageWidth);

  auto count = 0;
  foreach(y, ref row; parallel(outputBuffer))
    {
      foreach(x, ref pixel; parallel(row))
	{
	  pixel = generatePixel!(T,33)(x, y, renderContext);

	  write("\r" ~to!string(cast(int)(100*count++/cast(float)(imageWidth*imageHeight))));
	}
    }

  writeln();

  return outputBuffer;
}

void main()
{
  auto scene = Scene!float("public/scene1.scene");


  int multiplier = 2;

  auto renderContext = RenderContext!float( scene,
					    192*multiplier,
					    108*multiplier );


  auto imageBuffer = generateImageBuffer!float(renderContext);

  io.ppm.write("output.ppm",  imageBuffer );
 
  writeln("done");
}
