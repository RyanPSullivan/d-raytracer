module source.scene.model.box;

import source.scene.model.model;
import source.scene.model.collision;
import source.math.vector;
import source.math.matrix;
import source.math.ray;


import std.conv;
import std.stdio;
import std.math;

class Box(T) : Model!T
{
	this(T width, T depth, T height, Matrix!T transform)
	{
		super(transform);

		this.width = width;
		this.depth = depth;
		this.height = height;
	}
	
	override bool intersects(Ray!T r, ref Collision!T collision) 
	{
		auto inverseTransform = Matrix!T.invert(this.transformation);

		//move the ray into object space
		auto rOrig = inverseTransform.multVecMatrix(r.origin);
		auto rDir = inverseTransform.multDirMatrix(r.direction);

		Vector!T normal;

		auto maxX = this.width/2;
		auto minX = - maxX;
		auto maxY = this.height/2;
		auto minY = -maxX;
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
			return false;

		normal = Vector!T(1,0,0);

		if (tymin > tmin)
		{
			normal = Vector!T(0,1,0);
			tmin = tymin;
		}
		

		if (tymax < tmax)
			tmax = tymax;
		
		auto tzmin = (minZ - rOrig.z) / rDir.z;
		auto tzmax = (maxZ - rOrig.z) / rDir.z;
		
		if (tzmin > tzmax) 
		{
			swap(tzmin,tzmax);
		}
		
		if ((tmin > tzmax) || (tzmin > tmax))
			return false;
		
		if (tzmin > tmin)
		{
			normal = Vector!T(0,0,1);
			tmin = tzmin;
		}
		
		if (tzmax < tmax)
			tmax = tzmax;
		

		//writeln( to!string(tmin) ~ " " ~ to!string(tmax));
		collision.model = this;
		collision.distance = tmin;
		collision.hit = r.origin + tmin * r.direction;
		collision.normal= normal;

		return true;
	}
	
	private T width;
	private T depth;
	private T height;
}

