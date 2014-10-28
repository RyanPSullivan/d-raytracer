import std.stdio;
import std.stdio;
import std.math;
import std.conv;

import source.math.vector;
import source.math.matrix;

import source.scene.rendercontext;

import source.scene.model.model;
import source.scene.model.box3;
import source.scene.model.sphere;
import source.scene.camera;

import source.colour;
import source.math.ray;


struct Collision(T)
{
	bool occurred;
	Model!T object;
	Vector!T location;
	Vector!T normal;
}

Model!T[] getModels(T)()
{
	
	Model!T sphere = new Sphere!T(Vector!T(), 1, Matrix!T());
	Model!T box = new Box3!T(Vector!T(), Vector!T(), Matrix!T());
	
	return [sphere, box];
	
}
Ray!T calculateRayForPixel(T)( int x, int y, RenderContext renderContext)
{
	
	
	Matrix!float camToWorld = renderContext.camera.transform;
	
	auto rayOrigin = camToWorld.multVecMatrix(Vector!float());
	// remap from raster to screen space
	float xx = (2 * (x + 0.5) / x - 1) * renderContext.camera.angle * renderContext.imageAspectRatio;
	float yy = (1 - 2 * (y + 0.5) / y) * renderContext.camera.angle;
	
	// create the ray direction, looking down the z-axis
	// and transform by the camera-to-world matrix
	auto rayDirection = camToWorld.multDirMatrix(Vector!float(xx, yy, -1));
	
	return Ray!float(rayOrigin, Vector!float.normalize(rayDirection));
	
}

Collision!T intersect(T)(Model!T model, Ray!T ray)
{
	
	model.intersect(ray);
	Collision!T col;
	return col;
}

struct Light(T)
{
	Vector!T position;
	float brightness;
}
auto light = Light!float();
auto eyePosition = Vector!float(0,0,0);
auto lightPosition = Vector!float(0,0,0);

Collision!T getClosestCollision(T)(Ray!T ray)
{
	Collision!T returningCollision;
	
	auto minDistance = float.max;
	
	foreach(object; getModels!T())
	{
		auto collision = intersect( object, ray );
		auto distance = Vector!T.distance( ray.origin, collision.location);
		
		if( distance < minDistance )
		{
			returningCollision = collision;
			minDistance = distance;
		}
	}
	
	return returningCollision;
}

Ray!T computeReflectionRay(T)( Vector!T inDirection, Vector!T normal)
{
	return Ray!T();
}

Ray!T computeRefractiveRay(T)()
{
	return Ray!T();
}

Colour trace(T)(Ray!T ray, int depth)
{
	auto collision = getClosestCollision( ray );
	
	//no collision occured return a black pixel for now
	if( collision.occurred == false )
	{
		return Colour.BLACK;
	}
	
	Colour reflectionColour;
	Colour refractionColour;
	
	//ray collided with an object
	//reflection
	if( collision.object.isReflective )
	{
		auto reflectionRay = computeReflectionRay( ray.direction, collision.normal );
		
		reflectionColour = trace( reflectionRay, depth + 1 );
	}
	
	//refraction
	if( collision.object.isTransparent )
	{
		auto refractiveRay = computeRefractiveRay!float();
		
		refractionColour = trace( refractiveRay, depth + 1 );
	}
	
	//shadow
	Ray!T shadowRay;
	shadowRay.direction = lightPosition - collision.location;
	bool isShadow = false;
	foreach(object; getModels!T())
	{
		
		auto shadowCollision = intersect( object, shadowRay );
		if(  shadowCollision.occurred )
		{
			return Colour.BLACK;
		}
	}
	
	return collision.object.colour * light.brightness;
}

Colour generatePixel( int x, int y, RenderContext renderContext )
{
	auto ray = calculateRayForPixel!float(x,y, renderContext );
	
	return trace( ray, 0 ); 
}

void generateBitmap( string path, RenderContext renderContext )
{
	auto f = File(path, "w");
	auto imageWidth = renderContext.imageWidth;
	auto imageHeight = renderContext.imageHeight;
	
	//write header
	f.write("P6\n" ~ to!string(imageWidth) ~ " " ~ to!string(imageHeight) ~ "\n255\n");
	//write bitmap data
	foreach(y; 0..imageHeight)
	{
		foreach(x; 0..imageWidth)
		{
			auto pixel = generatePixel( x, y, renderContext);
			
			
			auto r = cast(char)fmax( 0.0f, fmin(255.0f, pow(pixel.r,1/2.2) * 255 + 0.5f));
			auto g = cast(char)fmax( 0.0f, fmin(255.0f, pow(pixel.g,1/2.2) * 255 + 0.5f));
			auto b = cast(char)fmax( 0.0f, fmin(255.0f, pow(pixel.b,1/2.2) * 255 + 0.5f));
			
			f.write( r );
			f.write( g );
			f.write( b );
		}
	}
	
	f.close();
}

void main()
{
	auto renderContext = RenderContext();

	auto identity = Matrix!float.identity;

	identity.translation = Vector!float(0,0,-5);

	renderContext.models[] = new Sphere!float(Vector!float(), 1, identity);

	identity.translation = Vector!float(1,1,6);

	renderContext.models[] = new Sphere!float(Vector!float(),1, identity);

	
	auto cameraTransform = Matrix!float.identity;
	cameraTransform.translation = Vector!float(0,0,5);

	renderContext.camera = Camera!float(cameraTransform,30);

	generateBitmap("output.ppm", renderContext);
}



