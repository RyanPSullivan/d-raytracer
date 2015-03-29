module source.scene.model.material;

import std.random;

public import source.colour;

struct Material
{
	this( Colour colour,
	     float coefficientOfReflection = 0 )
	{
		this.colour = colour;
		this.coefficientOfReflection = coefficientOfReflection;
	}

	public static immutable Material mirror = Material( Colour.white, 1 );

	@property bool isReflective() { return coefficientOfReflection != 0; }

	public Colour colour;
	/***
	 * 0 -> 1,
	 * 0 is non reflective 
	 * 1 is fully reflective
	 ***/
	public float coefficientOfReflection;

	
}

