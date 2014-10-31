module source.scene.rendercontext;

import source.scene.camera;
import source.scene.model.model;
import source.math.vector;
import source.colour;

import std.conv;
import std.stdio;

struct RenderContext(T)
{
	this(int imageWidth = 640, int imageHeight = 480)
	{
		this.imageWidth = imageWidth;
		this.imageHeight = imageHeight;
		this.imageAspectRatio = imageWidth / cast(float)imageHeight;
		this.backgroundColor = Colour(0.2, 0.3, 0.5, 0);
	}

	public Camera!T camera;
	uint imageWidth;
	uint imageHeight;
	float imageAspectRatio;
	Vector!T[] image;
	Model!T[] models;
	Colour backgroundColor;
}

