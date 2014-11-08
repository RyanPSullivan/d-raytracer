/* program prints a
 hello world message
 to the console.  */
module source.math.vector;

import core.simd;
import core.math;


struct Vector(T)
{

public:
	this( T x = 0, T y = 0, T z = 0, T w = 1)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	this( T[4] xyzw )
	{
		this.elements = xyzw;
	}
	
	float magnitudeSquared()
	{
		return (x * x) + (y * y) + (z * z);
	}

	float magnitude()
	{
		return sqrt( magnitudeSquared() );
	}

	void normalize()
	{
		auto mag = magnitude();

		x = x / mag;
		y = y / mag;
		z = z / mag;
	}

	Vector opBinary(string op)(Vector rhs) 
	{
		mixin("return Vector!T(this.x " ~ op ~ " rhs.x, this.y " ~ op ~ " rhs.y, this.z " ~ op ~ " rhs.z);");
	}

	Vector opBinaryRight( string op )( float scalar )
	{
		mixin("return Vector!T(this.x " ~ op ~ " scalar, this.y " ~ op ~ " scalar, this.z " ~ op ~ " scalar);");
	}

	Vector opBinary( string op )( float scalar )
	{
		mixin("return Vector!T(this.x " ~ op ~ " scalar, this.y " ~ op ~ " scalar, this.z " ~ op ~ " scalar);");
	}

	Vector opUnary(string op)() if( op == "-" )
	{
		return Vector(-this.x,-this.y,-this.z);
	}

	static float  distance( Vector lhs, Vector rhs ) 
	{
		return (lhs - rhs).magnitude;
	}

	static Vector normalize( Vector input )
	{
		input.normalize();

		return input;
	}

	static T dot( Vector lhs, Vector rhs )
	{
		return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
	}

	static Vector cross( Vector lhs, Vector rhs )
	{
		return Vector(lhs.y * rhs.z - lhs.z * rhs.y,
		              lhs.z * rhs.x - lhs.x * rhs.z,
		              lhs.x * rhs.y - lhs.y * rhs.x );
	}

	@property T x() { return elements[0]; }
	@property T x( T value ) { return elements[0] = value; }

	@property T y() { return elements[1]; }
	@property T y( T value ) { return elements[1] = value; }

	@property T z() { return elements[2]; }
	@property T z( T value ) { return elements[2] = value; }

	@property T w() { return elements[3]; }
	@property T w( T value ) { return elements[3] = value; }

	T[4] elements;
}

unittest
{
	//test subtraction
	auto result = Vector!float(1,0,0) - Vector!float(0,0,0);

	assert(result.x == 1 );

	
	//test multiple
	result = Vector!float(1,2,3) * 2;

	assert( result.x == 2 && result.y == 4 && result.z == 6 );
}
