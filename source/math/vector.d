/* program prints a
 hello world message
 to the console.  */
module source.math.vector;

import core.simd;
import core.math;

struct Vector(T)
{

public:
	this( T x, T y, T z, T w = 0)
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
		if( op == "-")
	{
		return Vector!T(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z, this.w - rhs.w);
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

	@property float x() { return elements[0]; }
	@property float x( float value ) { return elements[0] = value; }

	@property float y() { return elements[1]; }
	@property float y( float value ) { return elements[1] = value; }

	@property float z() { return elements[2]; }
	@property float z( float value ) { return elements[2] = value; }

	@property float w() { return elements[3]; }
	@property float w( float value ) { return elements[3] = value; }

private:

	T[4] elements;
}