module source.scene.light.point;

import source.math.vector;
import source.colour;

struct PointLight(T)
{
	this(Vector!T position, 
	     Colour diffuseColour = Colour.white, 
	     T diffusePower = 1, 
	     Colour specularColour = Colour.white, 
	     T specularPower = 1)
	{
		this.position = position;
		this.diffuseColour = diffuseColour;
		this.specularColour = specularColour;
		this.diffusePower = diffusePower;
		this.specularPower = specularPower;
	}

	Vector!T position;
	Colour diffuseColour;
	Colour specularColour;
	T  diffusePower;
	T  specularPower;
}
