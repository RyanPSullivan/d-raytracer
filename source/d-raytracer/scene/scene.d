module scene.scene;

import colour;
import scene.camera;
import scene.model.model;
import scene.model.plane;
import scene.model.sphere;
import scene.model.material;
import scene.model.collision;
import scene.light.point;

import math.matrix;
import math.vector;
import math.ray;

struct Scene(T)
{
  this(string filename)
  {
    import std.file;
    import std.utf;
    import std.string;
    import std.json;
  
    auto result = cast( string ) read( filename );

    validate( result );

    //  auto lines = result.splitLines();

    string output;

    foreach( line; splitLines(result)) 
      {
	if( !stripLeft(line).startsWith( "//") )
	  {
	    output ~= line ~ "\n";
	  }
      }

    auto json =  parseJSON( output );

    // TODO:
    // - support ambient light

    U parse(U,T)( JSONValue value )
    {
      import std.traits;
      import std.conv;

      static if( is(T == float) )
	{
	  return U( to!T(value[0].floating), to!T(value[1].floating), to!T(value[2].floating) );
	}
    }

    auto name = json["name"].str;
    auto ambientLight = parse!(Colour,float)(json["ambient_light"]);

    foreach( camera; json["cameras"].array() )
      {
	auto eye = camera["eye"];
	auto look = camera["look"];
	auto up = camera["up"];
    
	cameras ~= Camera!float( Matrix!float.createFromLookAt( parse!(Vector!float,float)( camera["eye"] ),
								parse!(Vector!float,float)( camera["look"] ),
								parse!(Vector!float,float)( camera["up"] ) ),
				 camera["focal_length"].floating,
				 camera["aperture"].floating );
      }

    Material[] materials;

    foreach( material; json["materials"].array() )
      {
	Colour reflectivity = Colour.white; 
	try
	  {
	    reflectivity =  parse!(Colour,float)( material["reflectivity"] );
	  }
	catch
	  {
	  }

	float refractivity = 0;
	try
	  {
	    refractivity = material["refractivity"].floating;
	  }
	catch
	  {
	  }
            
	materials ~= Material( parse!(Colour,float)( material["ambient"] ),
			       parse!(Colour,float)( material["diffuse"] ),
			       parse!(Colour,float)( material["specular"] ),
			       reflectivity,
			       refractivity );
      }

    foreach( light; json["lights"].array() )
      {
      
	switch(light["type"].str)
	  {
	  case "area":
	    lights ~= PointLight!(float)( parse!(Vector!float,float)( light["position"] ),
					  parse!(Colour, float )( light["intensity"] ) );
	    break;
	  
	  }
      }

      foreach( primitive; json["primitives"].array() )
      {
	Model!float  model;
      
	auto materialID = primitive["material_id"].integer;
	auto properties = primitive["properties"];
	auto material = materials[materialID];

	switch( primitive["type"].str )
	  {
	  case "plane":
	    model = new Plane!float( parse!(Vector!float,float)(properties["normal"]),
				     parse!(Vector!float,float)(properties["point"]),
				     material );
	    break;
	  case "sphere":
	    model = new Sphere!float( parse!(Vector!float,float)(properties["origin"]),
				      properties["radius"].floating,
				      material );
	    break;
	  
	  
	  }

	models ~= model;
      }
  }
Collision!T getClosestCollidingModel( Ray!T ray ){

  auto collision = Collision!T();
  collision.distance = T.max;
  foreach(model; models)
    {
      auto tempCollision = Collision!T();

      if( model.intersects( ray, tempCollision ) )
	{
	  if( tempCollision.distance < collision.distance 
	      && tempCollision.distance > ray.min
	      && tempCollision.distance < ray.max)
	    {
	      collision = tempCollision;
	    }
	}
    }

  return collision;
}
  public Colour trace( Ray!T ray, int depth )
  {
    import std.math;
    import math.ray;

    auto camera = cameras[0];
    auto collision = getClosestCollidingModel( ray );
	
    
    if( collision.model is null )
      {
	return Colour.black;
      }
    else
      {
	//return Colour.WHITE;
	//return Colour((collision.normal.x + 1)/2, (collision.normal.y + 1)/2, (collision.normal.z + 1)/2, 0);
		

	T lambertIntensity = 0;
	T specularIntensity = 0;
	Colour lightColour = Colour.white;

	foreach(light; lights)
	  {
	    auto vectorToLight = light.position - collision.hit;
	    auto directionToLight = Vector!T.normalize( vectorToLight );
	    auto directionToCamera = Vector!T.normalize( camera.transform.translation - collision.hit );

	    //dont apply this light if its obfuscated
  auto shadowRay = Ray!T( collision.hit, directionToLight, 0.01, vectorToLight.magnitude() );
	    auto shadowCollision = getClosestCollidingModel( shadowRay );

	    //the shadow ray didn't reach the light, continue to next light
	    if( shadowCollision.model !is null )
	      {
		continue;
	      }

	    //diffuse calulation
	    auto lightDot = Vector!T.dot( directionToLight, collision.normal );

	    if( lightDot < 0 ) lightDot = 0;

	    lambertIntensity += lightDot * light.diffusePower;
			
	    //specular calculation
	    auto camToLight = Vector!T.normalize(directionToLight + directionToCamera);
	    auto cameraDot = Vector!T.dot(collision.normal, camToLight);

	    if( cameraDot < 0 ) cameraDot = 0;

	    auto intensity = pow( cameraDot, 100 );

	    specularIntensity += intensity * light.specularPower; 

	    lightColour = lightColour + light.colour;
	  }

	auto shadingColour =(collision.model.material.ambient * lightColour * ((Colour(1,1,1,0) * 0f)) +
			     (collision.model.material.diffuse * lambertIntensity) +
			     (collision.model.material.specular* specularIntensity));

		
	if( depth < 2 && 
	    collision.model.material.isReflective )
	  {
	    auto kr = collision.model.material.reflectivity;

	    auto reflectionRay = Ray!T(collision.hit,
				       Vector!T.normalize(Vector!T.reflect(ray.direction,collision.normal)),
				       0.01);

	    auto reflectionColour = trace(reflectionRay, depth+1);

	    shadingColour = (shadingColour * (1.0f-kr)) + (reflectionColour * kr);
	  }

	return shadingColour;
      }
  }
  
  PointLight!(float)[] lights;  
  Model!float[] models;
  Camera!T[] cameras;
}
