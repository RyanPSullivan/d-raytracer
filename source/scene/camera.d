module source.scene.camera;


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
		this.worldTransform = worldTransform;
		this.inverseWorldTransform = Matrix!T.invert(worldTransform);
		this.angle = atan(degtorad(fov * 0.5));
	}

	private immutable T nearClippingPlane, farClippingPlane;
	private immutable T fov;
	private immutable T angle;
	private immutable Matrix!T worldTransform;
	private immutable Matrix!T inverseWorldTransform;
}

