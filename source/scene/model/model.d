module source.scene.model.model;

import std.random;
import source.math.ray;
import source.math.matrix;

import source.colour;

class Model(T)
{
	this( Matrix!T transformation )
	{
		this.transformation = transformation;
		this.shade = Colour(uniform(0, 255), uniform(0,255), uniform(0,255), 0);
	}

	abstract bool intersects( ref Ray!T ray );

	@property bool isTransparent() { return transparent; }
	@property bool isReflective() { return reflective; }
	@property Colour colour() { return this.shade; }

	private Matrix!T transformation;
	private Colour shade;
	private bool transparent;
	private bool reflective;

}

