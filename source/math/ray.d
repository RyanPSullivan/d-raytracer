﻿module source.math.ray;

import source.math.vector;

import std.stdio;
struct Ray(T)
{
	this( Vector!T origin, Vector!T direction, T near = 0, T far = T.infinity )
	{
		this.inverseDiretion =  -direction;
		this.direction = direction;
		this.origin = origin;
		this.min = near;
		this.max = far;
	}
	
	Vector!T direction;
	Vector!T origin;
	Vector!T inverseDiretion;
	T min;
	T max;
}