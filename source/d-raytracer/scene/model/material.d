module scene.model.material;

import std.random;

import colour;

struct Material
{
  this( Colour ambient,
	Colour diffuse,
	Colour specular,
	Colour reflectivity,
	float refractivity )
  {
    this.ambient = ambient;
    this.diffuse = diffuse;
    this.specular = specular;
    this.reflectivity = reflectivity;
    this.refractivity = refractivity;
  }

  public static immutable Material mirror = Material( Colour.white,
						      Colour.white,
						      Colour.white,
						      Colour.white,
						      1);

  @property bool isReflective() { return reflectivity != Colour.black; }
  @property bool isRefractive() { return refractivity != 1; }

  public Colour ambient;
  public Colour diffuse;
  public Colour specular;

  public Colour reflectivity;
  public float refractivity;
}

