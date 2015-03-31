module source.scene.model.material;

import std.random;

public import source.colour;

struct Material
{
  this( Colour ambient,
	Colour diffuse,
	Colour specular,
	Colour reflectivity,
	float refractivity )
  {
    
  }
	this( Colour colour,
	     float coefficientOfReflection = 0 )
	{
		this.colour = colour;
		this.coefficientOfReflection = coefficientOfReflection;
	}

  public static immutable Material mirror = Material( Colour.white,
						      Colour.white,
						      Colour.white,
						      Colour.white,
						      1);

  @property bool isReflective() { return reflectivity.lengthSquared != 0; }
  @property bool isRefractive() { return refractivity != 1; }

  public Colour ambient;
  public Colour diffuse;
  public Colour specular;

  public Colour reflectivity;
  public float refractivity;
}

