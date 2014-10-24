module source.colour;


struct Colour
{
	this( float red, float green, float blue, float alpha ) 
	{
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
	}
	
	static const Colour BLACK = Colour( 0, 0, 0, 0 );

	
	Colour opBinary(string op)(float scalar) if( op == "*")
	{
		return Colour( red * scalar, green * scalar, blue * scalar, alpha * scalar );
	}

	float red;
	float green;
	float blue;
	float alpha;
}