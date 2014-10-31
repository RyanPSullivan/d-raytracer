module source.scene.model.sphere;

import core.math;

import source.math.matrix;
import source.math.vector;
import source.math.ray;

import source.scene.model.model;

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
	override bool intersects(ref Ray!T ray, ref T t) 
	{
		auto rorig = transformation.multVecMatrix(ray.origin);

		auto rdir = transformation.multDirMatrix(ray.direction);

		T a = Vector!T.dot(rdir, rdir);
		T b = 2 * Vector!T.dot(rdir, rorig);
		T c = Vector!T.dot(rorig, rorig) - radiusSquared;
		T t0 = 0;
		T t1 = 0;
		if (!solveQuadratic(a, b, c, t0, t1) || t1 < 0) return false;

		if (t1 < t0) swap(t0, t1);

		
		t = (t0 < 0) ? t1 : t0; 

		return true;
	}

	private T radius;
	private T radiusSquared;
}



