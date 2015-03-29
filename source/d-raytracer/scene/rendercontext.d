module source.scene.rendercontext;

import source.scene.camera;
import source.scene.model.model;
import source.math.vector;
import source.colour;

import source.scene.light.point;

import std.conv;
import std.stdio;

struct RenderContext(T)
{
	this(uint width = 640, uint height = 480)
	{
		this.width = width;
		this.height = height;
		this.imageAspectRatio = width / cast(float)height;
		this.backgroundColor = Colour(0.2, 0.3, 0.5, 0);
	}

	public Camera!T camera;
	uint width;
	uint height;
	float imageAspectRatio;
	Vector!T[] image;
	Model!T[] models;
	Colour backgroundColor;
	PointLight!T[] pointLights;
}

