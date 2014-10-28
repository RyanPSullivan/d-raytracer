module source.scene.model.box3;

import source.scene.model.model;
import source.math.vector;
import source.math.matrix;
import source.math.ray;

class Box3(T) : Model!T
{
	this(Vector!T min, Vector!T max, Matrix!T transform)
	{
		super(transform);
		this.min = min;
		this.max = max;
	}

	protected override bool intersects( ref Ray!T r )
	{
		auto tmin = (min.x - r.origin.x) / r.direction.x;
		auto tmax = (max.x - r.origin.x) / r.direction.x;

		if (tmin > tmax) 
		{
			auto temp = tmax;
			tmax = tmin;
			tmin = temp;
		}

		auto tymin = (min.y - r.origin.y) / r.direction.y;
		auto tymax = (max.y - r.origin.y) / r.direction.y;

		if (tymin > tymax)
		{
			auto temp = tymax;
			tymax = tymin;
			tymin = temp;
		}

		if ((tmin > tymax) || (tymin > tmax))
			return false;

		if (tymin > tmin)
			tmin = tymin;

		if (tymax < tmax)
			tmax = tymax;

		auto tzmin = (min.z - r.origin.z) / r.direction.z;
		auto tzmax = (max.z - r.origin.z) / r.direction.z;

		if (tzmin > tzmax) 
		{
			auto temp = tzmax;
			tzmax = tzmin;
			tzmin = temp;
		}

		if ((tmin > tzmax) || (tzmin > tmax))
			return false;

		if (tzmin > tmin)
			tmin = tzmin;
		if (tzmax < tmax)
			tmax = tzmax;

		if ((tmin > r.max) || (tmax < r.min)) return false;

		if (r.min < tmin) r.min = tmin;
		if (r.max > tmax) r.max = tmax;

		
		return true;
	}

	

private:
	Vector!T min;
	Vector!T max;
}

