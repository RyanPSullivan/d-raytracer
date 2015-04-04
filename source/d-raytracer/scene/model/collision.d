module scene.model.collision;

import scene.model.model;
import math.vector;

struct Collision(T)
{
	Model!T model;
	Vector!T hit;
	Vector!T normal;
	T distance;
}
