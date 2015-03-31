module source.colour;

//import core.simd;

struct Colour
{
	this( float red, float green, float blue, float alpha = 1 ) 
	{
		this.r = red;
		this.g = green;
		this.b = blue;
		this.a = alpha;
	}

	this( float[4] rgba )
	{
		this.elements = rgba;
	}

	static immutable Colour white = Colour(1,1,1,0);
	static immutable Colour black = Colour( 0, 0, 0, 0 );
	static immutable Colour red = Colour( 1, 0, 0, 0 );
	static immutable Colour green = Colour( 0, 1, 0, 0 );
	
	Colour opBinary( string op )( Colour rhs )
		if( op == "*")
	{
		return Colour( r * rhs.r, g * rhs.g, b * rhs.b, a * rhs.a);
	}

	Colour opBinary(string op)(float scalar) 
	{
		mixin("return Colour( r " ~ op ~ " scalar, g " ~ op ~ " scalar, b " ~ op ~ " scalar, a " ~ op ~ " scalar );");
	}

	
	Colour opBinaryRight( string op )( float scalar )
	{
		mixin("return this " ~ op ~ "scalar;");
	}
	
	Colour opBinaryRight( string op )( Colour rhs ) if( op == "+")
	{
		return Colour( r + rhs.r, g + rhs.g, b + rhs.b, a + rhs.a);
	}

	@property  const float r() { return elements[0]; }
	@property float r( float value ) { return elements[0] = value; }
	
	@property const float g() { return elements[1]; }
	@property float g( float value ) { return elements[1] = value; }
	
	@property const float b() { return elements[2]; }
	@property float b( float value ) { return elements[2] = value; }
	
	@property const float a() { return elements[3]; }
	@property float a( float value ) { return elements[3] = value; }
	

	private float[4] elements;
}
