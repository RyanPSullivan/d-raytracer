module io.ppm;

import colour;

void write( string file, Colour[][] data )
{
  import std.stdio;
  import std.conv;
  import std.math;
  
    //write header
  auto f = File(file, "w");

  f.write("P6\n" ~ to!string(data[0].length) ~ " " ~ to!string(data.length) ~ "\n255\n");
  foreach( row; data)
    {
      foreach( pixel; row )
	{
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
