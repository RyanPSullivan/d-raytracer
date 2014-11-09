module source.colour;

import core.simd;

struct Colour
{
	this( float red, float green, float blue, float alpha ) 
	{
		this.r = red;
		this.g = green;
		this.b = blue;
		this.a = alpha;
	}

	this( float4 rgba )
	{
		this.elements = rgba;
	}

	static immutable Colour White = Colour(1,1,1,0);
	static immutable Colour Black = Colour( 0, 0, 0, 0 );
	static immutable Colour Red = Colour( 1, 0, 0, 0 );

	
	Colour opBinary( string op )( Colour rhs )
		if( op == "*")
	{
		return Colour( r * rhs.r, g * rhs.g, b * rhs.b, a * rhs.a);
	}

	Colour opBinary(string op)(float scalar) 
	{
		if( op == "*")
		{
			return Colour( r * scalar, g * scalar, b * scalar, a * scalar );
		}
		else if( op == "/")
		{
			return Colour( r / scalar, g / scalar, b / scalar, a / scalar );
		}
	}

	
	Colour opBinaryRight( string op)(float scalar ) if( op == "*")
	{
		return this * scalar;
	}

	Colour opBinaryRight( string op)( Colour rhs ) if( op == "+")
	{
		return Colour( r + rhs.r, g + rhs.g, b + rhs.b, a + rhs.a);
	}

	@property  const float r() { return elements.array[0]; }
	@property float r( float value ) { return elements.array[0] = value; }
	
	@property const float g() { return elements.array[1]; }
	@property float g( float value ) { return elements.array[1] = value; }
	
	@property const float b() { return elements.array[2]; }
	@property float b( float value ) { return elements.array[2] = value; }
	
	@property const float a() { return elements.array[3]; }
	@property float a( float value ) { return elements.array[3] = value; }
	

	private float4 elements;
}