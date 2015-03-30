import std.stdio;
import std.math;
import std.conv;
import std.random;
import std.parallelism;
import std.range;

import source.math.vector;
import source.math.matrix;

import source.scene.rendercontext;

import source.scene.light.point;
import source.scene.model.collision;
import source.scene.model.model;
import source.scene.model.box;
import source.scene.model.sphere;
import source.scene.model.plane;
import source.scene.camera;

import source.colour;
import source.math.ray;



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
		
		Colour lambertColour = Colour( 1, 1, 1, 0 );
		Colour specularColour = Colour( 1, 1, 1, 0 );

		T lambertIntensity = 0;
		T specularIntensity = 0;

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
			lambertColour = lambertColour * light.diffuseColour;

			//specular calculation
			auto camToLight = Vector!T.normalize(directionToLight + directionToCamera);
			auto cameraDot = Vector!T.dot(collision.normal, camToLight);

			if( cameraDot < 0 ) cameraDot = 0;

			auto intensity = pow( cameraDot, 100 );

			specularIntensity += intensity * light.specularPower; 

			specularColour = specularColour * light.specularColour;
		}

		auto shadingColour = collision.model.material.colour * ((Colour(1,1,1,0) * 0f) + (lambertColour * lambertIntensity) + (specularColour * specularIntensity));

		
		if( depth < 2 && 
		   collision.model.material.isReflective )
		{
			auto kr = collision.model.material.coefficientOfReflection;

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


void WriteToFile(string path, Colour[][] output)
{
	//write header
	auto f = File(path, "w");

	f.write("P6\n" ~ to!string(output[0].length) ~ " " ~ to!string(output.length) ~ "\n255\n");
	foreach( row; output)
	{
		foreach( pixel; row )
		{
			auto r = cast(char)(fmin(pixel.r * 255 + 0.5f, 255));
			auto g = cast(char)(fmin(pixel.g * 255 + 0.5f, 255));
			auto b = cast(char)(fmin(pixel.b * 255 + 0.5f, 255));
			
			f.write( r );
			f.write( g );
			f.write( b );
		}
	}
	
	f.close();
}

void createSceneOne(T)( ref RenderContext!T renderContext )
{
	auto identity = Matrix!float.identity;

	//bounding box
	identity.translation = Vector!float(0,0,15);

	renderContext.models ~= new Box!float(15,10,30,identity);

	//diagonal spheres and boxes
	identity.translation = Vector!float(2,2,5,1);
	
	renderContext.models ~= new Box!float(2,2,2,identity);
	
	identity.translation = Vector!float(-2, 2,5,1);
	
	renderContext.models ~= new Box!float(2,2,2,identity);
	
	identity.translation = Vector!float(-2,-2,5,1);
	
	renderContext.models ~= new Box!float(2,2,2,identity);
	
	identity.translation = Vector!float( 2, -2, 5, 1 );
	
	renderContext.models ~= new Box!float(2,2,2,identity);
	
	identity.translation = Vector!float(0,3,5,1);
	
	renderContext.models ~= new Sphere!float(identity);
	
	identity.translation = Vector!float(-3, 0,5,1);
	
	renderContext.models ~= new Sphere!float(identity);
	
	identity.translation = Vector!float( 0,-3,5,1);
	
	renderContext.models ~= new Sphere!float(identity);
	
	identity.translation = Vector!float( 3, 0, 5, 1 );
	
	renderContext.models ~= new Sphere!float(identity);

	//add the lights
	renderContext.pointLights ~= PointLight!float(Vector!float(-6, 0, 6));
	renderContext.pointLights ~= PointLight!float(Vector!float(6, 0, 6));
	renderContext.pointLights ~= PointLight!float(Vector!float(0, 0, 9));

}

void createSceneTwo(T)( ref RenderContext!T renderContext )
{
	auto transform = Matrix!T.identity;

	transform.translation = Vector!T(0,-1,0);
	renderContext.models ~= new Plane!T(transform);

	transform.translation = Vector!float( 2, 2, 5, 1 );

	auto newMatrix =  Matrix!T.createRotationY(2) * transform;

	renderContext.models ~= new Box!float(2,2,2, newMatrix);

	//add the lights
	renderContext.pointLights ~= PointLight!float(Vector!float(-6, 0, 6));
	renderContext.pointLights ~= PointLight!float(Vector!float(6, 0, 6));
	renderContext.pointLights ~= PointLight!float(Vector!float(0, 0, 9));

}


void createSceneThree(T)( ref RenderContext!T renderContext )
{
	auto identity = Matrix!T.identity;
	
	//bounding box
	identity.translation = Vector!T(0,0,0);
	
	renderContext.models ~= new Box!T(80,40,80,identity, Material(Colour(0.1f,0.1f,0.1f, 0), 0));

	//spheres

	identity.translation = Vector!T(5,0,-40);

	renderContext.models ~= new Sphere!T(identity, 20, Material(Colour.red, 0.8));

	identity.translation = Vector!T(-2,-18,7);
	
	renderContext.models ~= new Sphere!T(identity, 2, Material(Colour.green, 0));
	
	//add the lights
	renderContext.pointLights ~= PointLight!float(Vector!float(-6, 0, 6));
	renderContext.pointLights ~= PointLight!float(Vector!float(6, 0, 6));
	renderContext.pointLights ~= PointLight!float(Vector!float(0, 0, 9));	
}

void loadScene( string filename )()
{
  loadScene( filename );
}

void loadScene( string filename )
{
  import std.file;
  import std.utf;
  import std.string;
  import std.json;
  
  auto result = cast( string ) read( filename );

  validate( result );

  //  auto lines = result.splitLines();

  string output;

  foreach( line; splitLines(result)) 
  {
    if( !stripLeft(line).startsWith( "//") )
    {
	output ~= line ~ "\n";
    }
  }

  auto json =  parseJSON( output );

  // TODO:
  // - support ambient light

  pure Vector!T parseVector(T)( JSONValue value )
    {
      static if( isFloatingPoint(T) )
	{
	  return Vector!T( value[0].floating, value[1].floating, value[2].floating );
	}
    }
  foreach( camera; json["cameras"].array() )
  {
    auto eye = camera["eye"];
    auto look = camera["look"];
    auto up = camera["up"];
    
    Camera( Matrix!float.createFromLookAt( parseVector!float( camera["eye"] ),
					   parseVector!float( camera["look"] ),
					   parseVector!float( camera["up"] ) ),
				       	    camera["focal_length"],
	    camera["apature"] );
  }

  foreach( light; json["lights"] )
    {
      //TODO: Support light parsing 
    }

  Model[] models;
  foreach( primitive; json["primitives"] )
    {
      Model  model;
      switch( primitive["type"] )
	{
	case "plane":
	  model = Plane( primitive["normal"], primitive["point"] );
	  break;
	case "sphere":
	  model = Sphere( primitive["origin"], primitive["radius"] );
	  break;
	  
	  
	}

      models ~= model;
    }
  writeln( output );
}

void main()
{
       loadScene!"public/scene1.scene"();

       //loadScene("public/scene1.scene");

	int multiplier = 2;

	auto renderContext = RenderContext!float(192*multiplier,108*multiplier);

	//createSceneOne(renderContext);
	//createSceneTwo(renderContext);
	createSceneThree(renderContext);

	auto cameraTransform = Matrix!float.identity;
	cameraTransform.translation = Vector!float(0,-10,40,1);	

	renderContext.camera = Camera!float(cameraTransform,45);

	auto imageBuffer = generateImageBuffer!float(renderContext);

	WriteToFile("output.ppm", imageBuffer);
	writeln("done");
}
