/* program prints a
 hello world message
 to the console.  */
module math.vector;

import core.simd;
import core.math;


struct Vector
{

public:
	this( float x, float y, float z, float w = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	this( float4 xyzw )
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

	Vector opBinary(string op)(Vector rhs) if( op == "-")
	{
		return Vector(elements - rhs.elements);
	}

	static float  distance( Vector lhs, Vector rhs )
	{
		return (lhs - rhs).magnitude;
	}

	@property float x() { return elements.array[0]; }
	@property float x( float value ) { return elements.array[0] = value; }

	@property float y() { return elements.array[1]; }
	@property float y( float value ) { return elements.array[1] = value; }

	@property float z() { return elements.array[2]; }
	@property float z( float value ) { return elements.array[2] = value; }

	@property float w() { return elements.array[3]; }
	@property float w( float value ) { return elements.array[3] = value; }

private:
	float4 elements;

	
}