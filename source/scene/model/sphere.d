module source.scene.model.sphere;

import core.math;

import source.math.matrix;
import source.math.vector;
import source.math.ray;

import source.scene.model.model;

import source.scene.model.collision;

import std.stdio;
import std.conv;

class Sphere(T) : Model!T
{
	this(Matrix!T transform = Matrix!T.identity, float radius = 1 )
	{
		super(transform);
		this.radius = radius;
		this.radiusSquared = radius * radius;
	}

	void swap( ref T first, ref T second )
	{
		T temp = first;
		first = second;
		second = temp;
	}

	unittest
	{
		int a = 6;
		int b = 10;

		swap(a,b);

		assert( b == 6 && a == 10);
	}

	override bool intersects(Ray!T ray, ref Collision!T collision) 
	{
		auto rayorig = ray.origin; //transformation.multVecMatrix(ray.origin);
		auto raydir = ray.direction; //transformation.multDirMatrix(ray.direction);

		auto pos = transformation.translation;

		
		float a = Vector!T.dot(raydir,raydir);

		float b = Vector!T.dot(raydir , (2.0f * (rayorig-pos)));
		float c = Vector!T.dot(pos,pos) + Vector!T.dot(rayorig,rayorig) -2.0f*Vector!T.dot(rayorig,pos) - radiusSquared;
		float D = b*b + (-4.0f)*a*c;
		
		// If ray can not intersect then stop
		if (D < 0)
			return false;
		D=sqrt(D);
		
		// Ray can intersect the sphere, solve the closer hitpoint
		float t = (-0.5f)*(b+D)/a;
		if (t > 0.0f)
		{
			collision.model = this;
			collision.distance=sqrt(a)*t;
			collision.hit=rayorig + t*raydir;
			collision.normal=(collision.hit - pos) /radius;
		}
		else
			return false;

		return true;
	}

	
	private T radius;
	private T radiusSquared;
}



