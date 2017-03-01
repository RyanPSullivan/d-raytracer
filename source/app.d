import scene.scene;
import scene.rendercontext;
import std.file;
import std.string;
import std.stdio;
import io.ppm;

void main()
{

  auto path = "public/";
  auto files = dirEntries(path,"*.scene", SpanMode.shallow);

  foreach( DirEntry file; files )
  {
    writeln("Processing File " ~ file.name);
    auto scene = Scene!float(file.name);

    int multiplier = 2;

     auto renderContext = RenderContext!float( scene,
  					    192*multiplier,
					    108*multiplier );


    auto imageBuffer = renderContext.render( 0 );

    io.ppm.write(file.name.replace(".scene",".ppm"),  imageBuffer );
  }
}
