module source.scene.model.sphere;

import core.math;

import source.math.matrix;
import source.math.vector;
import source.math.ray;

import source.scene.model.model;

class Sphere(T) : Model!T
{
	this(Vector!T centre, T radius, Matrix!T transform) 
	{
		super(transform);
		this.centre = centre;
		this.radius = radius;
		this.diameter = 2 * radius;
	}

	// Constructor code
	override bool intersects(ref Ray!T ray) 
	{
		T t0, t1; // solutions for t if the ray intersects

		// geometric solution
		auto L = centre - ray.origin;
		auto tca = Vector!T.dot(L, ray.direction);
		if (tca < 0) return false;
		auto d2 = Vector!T.dot( L, L ) - tca * tca;
		if (d2 > diameter) return false;
		auto thc = sqrt(diameter - d2);
		t0 = tca - thc;
		t1 = tca + thc;
		//			// analytic solution
		//			Vec3<T> L = ray.origin - centre;
		//			T a = ray.dir.dot(ray.dir);
		//			T b = 2 * ray.dir.dot(L);
		//			T c = L.dot(L) - diameter;
		//			if (!solveQuadratic(a, b, c, t0, t1)) return false;
		//#endif
		if (t0 > ray.max) 
		{
			return false;
		}

		ray.max = t0;
		return true;
	}

	private Vector!T centre;
	private T radius;
	private T diameter;
}



