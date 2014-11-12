module source.scene.model.model;


import source.math.ray;
import source.math.matrix;
public import source.scene.model.material;
import source.scene.model.collision;

import source.colour;

class Model(T)
{

	this( Matrix!T transformation, Material material )
	{
		this.material = material;
		this.transformation = transformation;
	}

	abstract bool intersects( Ray!T ray, ref Collision!T collision );

	
	protected Matrix!T transformation;
	public Material material;
}

