module source.scene.camera;

import std.math;

import source.math.matrix;

/**
 * Ryan Ryan Ryan 
 * Camera Camera Camera
 **/
struct Camera(T)
{
	this(Matrix!T worldTransform = Matrix!T.identity,
	     float fov = 90,
	     float nearClippingPane = 0.1,
	     float farClippingPlane = 1000 )
	{

		this.nearClippingPlane = nearClippingPane;
		this.farClippingPlane = farClippingPlane;
		this.fov = fov;
		this.transform = worldTransform;
		this.angle = atan((fov * 0.5) * 0.0174532925);
	}

	public  T nearClippingPlane, farClippingPlane;
	public  T fov;
	public  T angle;
	public  Matrix!T transform;
}

