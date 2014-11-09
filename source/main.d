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

	
	//no collision occured return a black pixel for now                                                                                                                                                                      
	if( collision.model is null )
	{
		return renderContext.backgroundColor;
	}
	else
	{
		//return Colour.WHITE;
		//return Colour(abs(collision.normal.x), abs(collision.normal.y), abs(collision.normal.z), 0);

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
			auto shadowRay = Ray!T( collision.hit, directionToLight, 0.00001, vectorToLight.magnitude() );
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

		return collision.model.colour * ((Colour(1,1,1,0) * 0f) + (lambertColour * lambertIntensity) + (specularColour * specularIntensity));
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
		float pixelWidth = 1.0f / renderContext.width;
		float pixelHeight = 1.0f / renderContext.height;

		int focusPoint = 2;
		Colour result = Colour(0,0,0,0);

		//Now here I compute point P in the scene where I want to focus my scene
		auto P = originalRay.origin + focusPoint * originalRay.direction;

		auto samples = 16;

		//Stratified Sampling i.e. Random sampling (with 16 samples) inside each pixel to add DOF
		foreach( i; 0..samples)
		{
			float rw  = uniform(-1.0f,1.0f);
			float rh  = uniform(-1.0f,1.0f);
			
			float dx =  ( (rw) * 3 * pixelWidth) ;
			float dy =  ( (rh) * 3 * pixelHeight);
			
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

	foreach(y, ref row; parallel(outputBuffer))
	{
		foreach(x, ref pixel; parallel(row))
		{
			pixel = generatePixel!(T,0)(imageWidth - x, imageHeight - y, renderContext);
		}
	}

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

void main()
{
	int multiplier = 10;
	auto renderContext = RenderContext!float(192*multiplier,108*multiplier);
	//auto renderContext = RenderContext!float(4096,4096);
	auto identity = Matrix!float.identity;

	
	//big box around everything

	identity.translation = Vector!float(0,0,15);
	renderContext.models ~= new Box!float(15,10,30,identity);

	
	//diagonal spheres
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

	auto cameraTransform = Matrix!float.identity;
	cameraTransform.translation = Vector!float(0,0,20,1);	

	renderContext.camera = Camera!float(cameraTransform,45);

	auto imageBuffer = generateImageBuffer!float(renderContext);

	
	writeln("done");
}



