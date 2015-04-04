module scene.scene;

import colour;
import scene.camera;
import scene.model.model;
import scene.model.plane;
import scene.model.sphere;
import scene.model.material;

import scene.light.point;

import math.matrix;
import math.vector;

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
  
    Camera!float[] cameras;

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

    PointLight!(float)[] lights;
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

    Model!float[] models;
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
}
