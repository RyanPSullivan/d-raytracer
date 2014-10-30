module source.scene.rendercontext;

import source.scene.camera;
import source.scene.model.model;
import source.math.vector;
import source.colour;

import std.conv;
import std.stdio;

struct RenderContext
{
	this(int imageWidth = 640, int imageHeight = 480)
	{
		this.imageWidth = imageWidth;
		this.imageHeight = imageHeight;
		this.imageAspectRatio = imageWidth / cast(float)imageHeight;
		this.backgroundColor = Colour(0.2, 0.3, 0.5, 0);
	}

	public Camera!float camera;
	uint imageWidth;
	uint imageHeight;
	float imageAspectRatio;
	Vector!float[] image;
	Model!float[] models;
	Colour backgroundColor;
}

