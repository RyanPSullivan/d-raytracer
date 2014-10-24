import std.stdio;

import math.vector;
import scene.object;
import source.colour;
import source.pixel;

struct Ray
{
	this( Vector direction, Vector origin )
	{
		this.direction = direction;
		this.origin = origin;
	}

	Vector direction;
	Vector origin;
}

struct Collision
{
	bool occurred;
	SceneObject object;
	Vector location;
	Vector normal;
}

Ray calculateRayForPixel( int x, int y )
{
	return Ray();
}

Collision intersect(SceneObject object, Ray ray)
{
	Collision col;
	return col;
}

struct Light
{
	Vector position;
	float brightness;
}
auto light = Light();
auto eyePosition = Vector(0,0,0);
auto objects = [SceneObject(), SceneObject(), SceneObject()];
auto lightPosition = Vector(0,0,0);

Collision getClosestCollision(Ray ray)
{
	Collision returningCollision;

	auto minDistance = float.max;

	foreach(object; objects)
	{
		auto collision = intersect( object, ray );
		auto distance = Vector.distance( ray.origin, collision.location);
		
		if( distance < minDistance )
		{
			returningCollision = collision;
			minDistance = distance;
		}
	}

	return returningCollision;
}







Ray computeReflectionRay( Vector inDirection, Vector normal)
{
	return Ray();
}

Ray computeRefractiveRay()
{
	return Ray();
}

Colour trace(Ray ray, int depth)
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
		auto refractiveRay = computeRefractiveRay();
		
		refractionColour = trace( refractiveRay, depth + 1 );
	}
	
	//shadow
	Ray shadowRay;
	shadowRay.direction = lightPosition - collision.location;
	bool isShadow = false;
	foreach(object; objects)
	{
		auto shadowCollision = intersect( object, shadowRay );
		if(  shadowCollision.occurred )
		{
			return Colour.BLACK;
		}
	}

	return collision.object.colour * light.brightness;
}

Colour generatePixel( int x, int y )
{
	auto ray = calculateRayForPixel(x,y);

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
