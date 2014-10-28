module source.math.matrix;

import source.math.vector;

struct Matrix(T)
{

	this(T m11, T m12, T m13, T m14,
	     T m21, T m22, T m23, T m24,
	     T m31, T m32, T m33, T m34,
	     T m41, T m42, T m43, T m44 )
	{
		m[0][0] = m11; m[0][1] = m12; m[0][2] = m13; m[0][3] = m14;
		m[1][0] = m21; m[1][1] = m22; m[1][2] = m23; m[1][3] = m24;
		m[2][0] = m31; m[2][1] = m32; m[2][2] = m33; m[2][3] = m34;
		m[3][0] = m41; m[3][1] = m42; m[3][2] = m43; m[3][3] = m44;
	}

	Vector!T multVecMatrix( Vector!T src ) const
	{
		float x,y,z;

		x = src.x * m[0][0] + src.y * m[1][0] + src.z * m[2][0] + m[3][0];
		y = src.x * m[0][1] + src.y * m[1][1] + src.z * m[2][1] + m[3][1];
		z = src.x * m[0][2] + src.y * m[1][2] + src.z * m[2][2] + m[3][2];
		T w = src.x * m[0][3] + src.y * m[1][3] + src.z * m[2][3] + m[3][3];
		if (w != 1 && w != 0) {
			x /= w;
			y /= w;
			z /= w;
		}

		return Vector!T(x,y,z);
	}

	Vector!T multDirMatrix(Vector!T src) const
	{
		return Vector!T(
			src.x * m[0][0] + src.y * m[1][0] + src.z * m[2][0],
		src.x * m[0][1] + src.y * m[1][1] + src.z * m[2][1],
		src.x * m[0][2] + src.y * m[1][2] + src.z * m[2][2] );
	}

	public static Matrix invert( Matrix mat )
	{
		return identity();
	}
	
	public static Matrix identity()
	{
		return Matrix(1, 0, 0, 0,
		              0, 1, 0, 0,
		              0, 0, 1, 0,
		              0, 0, 0, 1 );
	}

	@property Vector!T translation() { return Vector!float(m[3]); }
	@property void translation( Vector!T value ) 
	{ 
		m[3][0] = value.x; m[3][1] = value.y; m[3][2] = value.z; m[3][3] = value.w;

	}
	
	private T[4][4] m;
}

