module source.scene.model.collision;

import source.scene.model.model;
import source.math.vector;

struct Collision(T)
{
	Model!T model;
	Vector!T hit;
	Vector!T normal;
	T distance;
}
