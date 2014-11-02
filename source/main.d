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
	Model!T model;
	Vector!T hit;
}

Ray!T calculateRayForPixel(T)( int x, int y, RenderContext!T renderContext)
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

Collision!T getClosestCollidingModel(T)(Ray!T ray, Model!T[] models){
	auto minDistance = T.max;
	Model!T collidingModel = null;
	foreach(model; models)
	{
		T distance = 0;
		if( model.intersects( ray, distance ) )
		{
			if( distance < minDistance && distance > ray.min  )
			{
				collidingModel = model;
				minDistance = distance;
			}
		}
	}

	auto collision = Collision!T();
	
	collision.model = minDistance < ray.max ? collidingModel : null;
	collision.hit = ray.origin + (ray.direction * (minDistance - 0.01)); //TODO:this magic number needs removing.

	return collision;
}

Vector!float lightPosition = Vector!float(4, 0 -4, 1);

Colour trace(T)(Ray!T ray, int depth, RenderContext!T renderContext)
{
	auto collision = getClosestCollidingModel!T( ray, renderContext.models );

	
	//no collision occured return a black pixel for now                                                                                                                                                                      
	if( collision.model is null )
	{
		return renderContext.backgroundColor;
	}
	else
	{
		auto direction = Vector!float.normalize(lightPosition - collision.hit);

		//lets do some shading
		auto shadowRay = Ray!T( collision.hit, direction);

		auto shadowCollision = getClosestCollidingModel( shadowRay, renderContext.models );

		if( shadowCollision.model is null)
		{
			return collision.model.colour;
		}
		else
		{
			//writeln("in shadow " ~ to!string(shadowCollision.hit) ~ "  " ~ to!string(shadowRay.origin));
			//return Colour.RED;

			return collision.model.colour * 0.2;
		}
	}
}

Colour generatePixel(T)( int x, int y, RenderContext!T renderContext )
{
	auto ray = calculateRayForPixel!float(x,y, renderContext );

	return trace!float( ray, 0, renderContext ); 
}

void generateBitmap(T)( string path, RenderContext!T renderContext )
{
	auto f = File(path, "w");
	auto imageWidth = renderContext.imageWidth;
	auto imageHeight = renderContext.imageHeight;

	
	//generatePixel( 900, 438, renderContext);

	//write header
	f.write("P6\n" ~ to!string(imageWidth) ~ " " ~ to!string(imageHeight) ~ "\n255\n");
	//write bitmap data
	foreach(y; 0..imageHeight)
	{
		foreach(x; 0..imageWidth)
		{
			auto pixel = generatePixel( imageWidth - x, imageHeight - y, renderContext);
			
			auto r = cast(char)(fmin(pixel.r * 255 + 0.5f, 255));
			auto g = cast(char)(fmin(pixel.g * 255 + 0.5f, 255));
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
	auto renderContext = RenderContext!float(1920,1080);
	//auto renderContext = RenderContext!float(4096,4096);
	auto identity = Matrix!float.identity;

	identity.translation = Vector!float(0,0,-4,1);
	
	renderContext.models ~= new Sphere!float(identity);

	identity.translation = Vector!float(-1,-2,-4,1);
	
	renderContext.models ~= new Sphere!float(identity);

	identity.translation = Vector!float(-2,-4,-4,1);
	
	renderContext.models ~= new Sphere!float(identity);

	
	renderContext.models ~= new Sphere!float(identity);
	
	auto cameraTransform = Matrix!float.identity;
	cameraTransform.translation = Vector!float(0,0,20,1);	

	renderContext.camera = Camera!float(cameraTransform,30);

	generateBitmap("output.ppm", renderContext);

	writeln("done");
}



