module source.scene.model.box;

import source.scene.model.model;
import source.scene.model.collision;
import source.math.vector;
import source.math.matrix;
import source.math.ray;

import std.algorithm;
import std.conv;
import std.stdio;
import std.math;

class Box(T) : Model!T
{
	this(T width, T height, T depth, Matrix!T transform)
	{
		writeln(to!string(transform));
		super(transform);

		this.width = width;
		this.height = height;
		this.depth = depth;

		reflective = false;
	}

	
	override bool intersects(Ray!T r, ref Collision!T collision) 
	{
		auto inverseTransform = Matrix!T.invert(this.transformation);

		//move the ray into object space
		auto rOrig = inverseTransform.multVecMatrix(r.origin);
		auto rDir = inverseTransform.multDirMatrix(r.direction);

		//start ray at minimum point
		rOrig = rOrig + rDir * r.min;

		Vector!T minN;
		Vector!T maxN;

		auto maxX = this.width/2;
		auto minX = - maxX;
		auto maxY = this.height/2;
		auto minY = -maxY;
		auto maxZ = this.depth/2;
		auto minZ = -maxZ;

		
		auto tmin = (minX - rOrig.x) / rDir.x;
		auto tmax = (maxX - rOrig.x) / rDir.x;

		if (tmin > tmax) 
		{
			swap(tmin,tmax);
		}
		
		auto tymin = (minY - rOrig.y) / rDir.y;
		auto tymax = (maxY - rOrig.y) / rDir.y;

		
		if (tymin > tymax)
		{
			swap(tymin,tymax);
		}
		
		if ((tmin > tymax) || (tymin > tmax))
		{

			return false;
		}
		

		minN = Vector!T( 1,0,0 );
		maxN = Vector!T( 1,0,0 );

		if (tymin > tmin)
		{
			minN = Vector!T(0,1,0);
			tmin = tymin;
		}
		

		if (tymax < tmax)
		{
			maxN = Vector!T(0,1,0);
			tmax = tymax;
		}
		
		
		auto tzmin = (minZ - rOrig.z) / rDir.z;
		auto tzmax = (maxZ - rOrig.z) / rDir.z;
		
		if (tzmin > tzmax) 
		{
			swap(tzmin,tzmax);
		}
		
		if ((tmin > tzmax) || (tzmin > tmax))
		{
			return false;
		}
		
		if (tzmin > tmin)
		{
			minN = Vector!T(0,0,1);
			tmin = tzmin;
		}
		
		if (tzmax < tmax)
		{ 
			maxN = Vector!T(0,0,1);
			tmax = tzmax;
		}

		//if the minimum point is behind us we dont care,
		//we are inside the box, use the max intersection
		if( tmin < 0)
		{
			tmin = tmax;
			minN = maxN;
		}

		//the normal should not be in the same direction as the ray,
		//if it is we need to flip it.
		if( Vector!T.dot( minN, rDir ) > 0 )
		{
			minN = minN * -1;
		}

		collision.model = this;
		collision.distance = tmin;
		collision.hit = r.origin +  tmin * r.direction;
		collision.normal = transformation.multDirMatrix(minN);

		

		return true;
	}
	
	private T width;
	private T depth;
	private T height;
}

