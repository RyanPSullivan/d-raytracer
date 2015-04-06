module scene.camera;

import std.math;

import math.matrix;

/**
 * Ryan Ryan Ryan 
 * Camera Camera Camera
 **/
struct Camera(T)
{
  this( Matrix!T worldTransform = Matrix!T.identity,
	T focalLength = 0,
	T aperture = 0,
	T fov = 90,
	T farClippingPlane = 100000,
	T nearClippingPlane = 0.1 )
  {
    this.nearClippingPlane = nearClippingPlane;
    this.farClippingPlane = farClippingPlane;
    this.fov = fov;
    this.transform = worldTransform;
    this.angle = atan((fov * 0.5) * 0.0174532925);
    this.focalLength = focalLength;
    this.aperture = aperture;
  }

  public  T nearClippingPlane, farClippingPlane;
  public  T fov;
  public  T angle;
  public T focalLength;
  public T aperture;
  public Matrix!T transform;
}


