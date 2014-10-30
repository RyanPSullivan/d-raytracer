import std.stdio;
import std.stdio;
import std.math;
import std.conv;

import source.math.vector;
import source.math.matrix;

import source.scene.rendercontext;

import source.scene.model.model;
import source.scene.model.box3;
import source.scene.model.sphere;
import source.scene.camera;

import source.colour;
import source.math.ray;


struct Collision(T)
{
	bool occurred;
	Model!T object;
}

Ray!T calculateRayForPixel(T)( int x, int y, RenderContext renderContext)
{
	Matrix!float camToWorld = renderContext.camera.transform;
	
	auto rayOrigin = camToWorld.multVecMatrix(Vector!float(0,0,0));

	// remap from raster to screen space
	float xx = (2 * ((x + 0.5) / renderContext.imageWidth) - 1)  * renderContext.camera.angle * renderContext.imageAspectRatio;
	float yy = (1 - 2 *((y + 0.5) / renderContext.imageHeight))  * renderContext.camera.angle;
	
	// create the ray direction, looking down the z-axis
	// and transform by the camera-to-world matrix
	auto rayDirection = camToWorld.multDirMatrix(Vector!float(xx, yy, -1));
	
	return Ray!float( rayOrigin, 
	                 Vector!float.normalize(rayDirection), 
	                 renderContext.camera.nearClippingPlane, 
	                 renderContext.camera.farClippingPlane);
	
}

Model!T getClosestCollidingModel(T)(Ray!T ray, Model!T[] models){
	auto minDistance = T.max;
	Model!T collidingModel = null;
	foreach(model; models)
	{
		auto distance = 0.0f;
		if( model.intersects( ray, distance ) )
		{
			if( distance < minDistance && distance > ray.min  )
			{
				collidingModel = model;
				minDistance = distance;
			}
		}
	}
	
	return minDistance < ray.max ? collidingModel : null;
}

Colour trace(T)(Ray!T ray, int depth, RenderContext renderContext)
{
	auto model = getClosestCollidingModel( ray, renderContext.models );
	
	//no collision occured return a black pixel for now
	if( model is null )
	{
		return renderContext.backgroundColor;
	}
	else
	{
		return model.colour;
	}
}

Colour generatePixel( int x, int y, RenderContext renderContext )
{
	auto ray = calculateRayForPixel!float(x,y, renderContext );

	

	return trace!float( ray, 0, renderContext ); 
}

void generateBitmap( string path, RenderContext renderContext )
{
	auto f = File(path, "w");
	auto imageWidth = renderContext.imageWidth;
	auto imageHeight = renderContext.imageHeight;
	
	//write header
	f.write("P6\n" ~ to!string(imageWidth) ~ " " ~ to!string(imageHeight) ~ "\n255\n");
	//write bitmap data
	foreach(y; 0..imageHeight)
	{
		foreach(x; 0..imageWidth)
		{
			auto pixel = generatePixel( x, y, renderContext);

			auto r = cast(char)(fmin(pixel.r * 255 + 0.5f, 255));
			auto g = cast(char)(fmin(pixel.g * 255  + 0.5f, 255));
			auto b = cast(char)(fmin(pixel.b * 255 + 0.5f, 255));
			
			f.write( r );
			f.write( g );
			f.write( b );
		}
	}
	
	f.close();
}

void main()
{
	auto renderContext = RenderContext(640,480);

	auto identity = Matrix!float.identity;
	foreach(i; 1 .. 15)
	{
		identity.translation = Vector!float(1,1,-(i * 2),1);
		
		renderContext.models ~= new Sphere!float(identity);
	}

	writeln(identity);
	renderContext.models ~= new Sphere!float(identity);
	
	auto cameraTransform = Matrix!float.identity;
	cameraTransform.translation = Vector!float(0,0,10,1);	

	renderContext.camera = Camera!float(cameraTransform,30);

	generateBitmap("output.ppm", renderContext);
}



