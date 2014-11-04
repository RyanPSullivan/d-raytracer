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

	
	bool solveQuadratic(const ref T a, const ref T b, const ref T c, ref T x0, ref T x1)
	{
		T discr = b * b - 4 * a * c;
		if (discr <= 0) return false;
		//else if (discr == 0) x0 = x1 = - 0.5 * b / a;
		//else {
		T q = (b < 0) ? -0.5 * (b - sqrt(discr)) : -0.5 * (b + sqrt(discr));
		x0 = q / a;
		x1 = c / q;

		if (x0 > x1) 
			swap(x0, x1);
		return true;
	}

	// Constructor code
	void intersects(Ray!T ray, ref Collision!T collision) 
	{
		auto rorig = transformation.multVecMatrix(ray.origin);
		auto rdir = transformation.multDirMatrix(ray.direction);

		T a = Vector!T.dot(rdir, rdir);
		T b = 2 * Vector!T.dot(rdir, rorig);
		T c = Vector!T.dot(rorig, rorig) - radiusSquared;
		T t0 = 0;
		T t1 = 0;
		if (!solveQuadratic(a, b, c, t0, t1) || t1 < 0) return;

		if (t1 < t0) 
			swap(t0, t1);

		T t = (t0 < 0) ? t1 : t0; 

		collision.model = this;
		collision.distance = t;
		collision.hit = rorig + rdir * (t - 0); //remove magic number
		collision.normal = (collision.hit - transformation.translation)/radius;

		
		return;
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
			collision.distance=t;//sqrt(a)*t;
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



