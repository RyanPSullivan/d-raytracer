import scene.scene;
import scene.rendercontext;

import io.ppm;

void main()
{
  auto scene = Scene!float("public/scene1.scene");


  int multiplier = 2;

  auto renderContext = RenderContext!float( scene,
					    192*multiplier,
					    108*multiplier );


  auto imageBuffer = renderContext.render( 1 );

  io.ppm.write("output.ppm",  imageBuffer );
}
