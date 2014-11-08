module source.scene.model.model;

import std.random;
import source.math.ray;
import source.math.matrix;

import source.scene.model.collision;

import source.colour;

class Model(T)
{

	this( Matrix!T transformation )
	{
		this.transformation = transformation;
		this.shade = Colour( uniform( 0.0f, 1.0f ), uniform( 0.0f, 1.0f ), uniform( 0.0f, 1.0f ), 0 );
	}

	protected static void swap( ref T first, ref T second )
	{
		T temp = first;
		first = second;
		second = temp;
	}

	abstract bool intersects( Ray!T ray, ref Collision!T collision );

	@property bool isTransparent() { return transparent; }
	@property bool isReflective() { return reflective; }
	@property Colour colour() { return this.shade; }

	protected Matrix!T transformation;
	private Colour shade;
	private bool transparent;
	private bool reflective;

	unittest
	{
		T a = 6;
		T b = 10;
		
		swap(a,b);
		
		assert( b == 6 && a == 10);
	}
}

