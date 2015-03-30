﻿module source.scene.model.plane;

import std.stdio;
import std.conv;

import source.scene.model.model;

import source.math.vector;
import source.math.matrix;
import source.math.ray;

import source.scene.model.collision;


class Plane(T) : Model!T 
{
	this( Matrix!T transform )
	{
		super(transform, Material(Colour.red, 0.9));
	}

	override bool intersects(Ray!T r, ref Collision!T collision) 
	{
		auto inverseTransform = Matrix!T.invert(this.transformation);
		
		//move the ray into object space
		auto rOrig = inverseTransform.multVecMatrix(r.origin);
		auto rDir = inverseTransform.multDirMatrix(r.direction);

		//writeln(to!string(inverseTransform));
		//in object space the plane is aligned with the x,z plane, normal is (0,1,0)
		auto denominator = Vector!T.dot(rDir,Vector!T.up);

		//line and plane are parallel
		if( denominator == 0 )
		{
			return false;
		}

		auto numerator = Vector!T.dot(Vector!T(0,0,0) - rOrig, Vector!T.up);

		//point runs parralel to plane
		if( numerator == 0)
		{
			return false;
		}
		
		float d = numerator/denominator;

		collision.model = this;
		collision.distance = d;
		collision.hit = r.origin +  d * r.direction;
		collision.normal = Vector!T.dot( Vector!T.up, rDir ) < 0 ? transformation.up : transformation.down;

		return true;
	}
}
