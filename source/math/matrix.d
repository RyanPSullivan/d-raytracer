module source.math.matrix;

import std.stdio;
import std.math;
import std.conv;

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

	this( T[4][4] m )
	{
		this.m = m;
	}

	this( T[16] m)
	{
		this.m = m;
	}

	Vector!T multVecMatrix( Vector!T src) 
	{
		T x = src.x * m[0][0] + src.y * m[1][0] + src.z * m[2][0] + m[3][0];
		T y = src.x * m[0][1] + src.y * m[1][1] + src.z * m[2][1] + m[3][1];
		T z = src.x * m[0][2] + src.y * m[1][2] + src.z * m[2][2] + m[3][2];
		T w = src.x * m[0][3] + src.y * m[1][3] + src.z * m[2][3] + m[3][3];

		if( w == 0 )
		{
			return Vector!T(x,y,z,1);
		}
		else
		{
			return Vector!T( x/w, y/w, z/w, 1 );
		}
	}

	Vector!T multDirMatrix(Vector!T src) const
	{
		return Vector!T(
			src.x * m[0][0] + src.y * m[1][0] + src.z * m[2][0],
		src.x * m[0][1] + src.y * m[1][1] + src.z * m[2][1],
		src.x * m[0][2] + src.y * m[1][2] + src.z * m[2][2] );
	}

	
	public T opIndex(size_t i)
	{
		return m[i/4][i%4];
	}

	public void opIndexAssign( T value, size_t i, size_t j)
	{
		m[i][j] = value;
	}

	public static Matrix invert( Matrix m )
	{
		T inv[16]; 
		T det;
		int i;
		
		inv[0] = m[5]  * m[10] * m[15] - 
			m[5]  * m[11] * m[14] - 
			m[9]  * m[6]  * m[15] + 
			m[9]  * m[7]  * m[14] +
			m[13] * m[6]  * m[11] - 
			m[13] * m[7]  * m[10];
		
		inv[4] = -m[4]  * m[10] * m[15] + 
			m[4]  * m[11] * m[14] + 
			m[8]  * m[6]  * m[15] - 
			m[8]  * m[7]  * m[14] - 
			m[12] * m[6]  * m[11] + 
			m[12] * m[7]  * m[10];
		
		inv[8] = m[4]  * m[9] * m[15] - 
			m[4]  * m[11] * m[13] - 
			m[8]  * m[5] * m[15] + 
			m[8]  * m[7] * m[13] + 
			m[12] * m[5] * m[11] - 
			m[12] * m[7] * m[9];
		
		inv[12] = -m[4]  * m[9] * m[14] + 
			m[4]  * m[10] * m[13] +
			m[8]  * m[5] * m[14] - 
			m[8]  * m[6] * m[13] - 
			m[12] * m[5] * m[10] + 
			m[12] * m[6] * m[9];
		
		inv[1] = -m[1]  * m[10] * m[15] + 
			m[1]  * m[11] * m[14] + 
			m[9]  * m[2] * m[15] - 
			m[9]  * m[3] * m[14] - 
			m[13] * m[2] * m[11] + 
			m[13] * m[3] * m[10];
		
		inv[5] = m[0]  * m[10] * m[15] - 
			m[0]  * m[11] * m[14] - 
			m[8]  * m[2] * m[15] + 
			m[8]  * m[3] * m[14] + 
			m[12] * m[2] * m[11] - 
			m[12] * m[3] * m[10];
		
		inv[9] = -m[0]  * m[9] * m[15] + 
			m[0]  * m[11] * m[13] + 
			m[8]  * m[1] * m[15] - 
			m[8]  * m[3] * m[13] - 
			m[12] * m[1] * m[11] + 
			m[12] * m[3] * m[9];
		
		inv[13] = m[0]  * m[9] * m[14] - 
			m[0]  * m[10] * m[13] - 
			m[8]  * m[1] * m[14] + 
			m[8]  * m[2] * m[13] + 
			m[12] * m[1] * m[10] - 
			m[12] * m[2] * m[9];
		
		inv[2] = m[1]  * m[6] * m[15] - 
			m[1]  * m[7] * m[14] - 
			m[5]  * m[2] * m[15] + 
			m[5]  * m[3] * m[14] + 
			m[13] * m[2] * m[7] - 
			m[13] * m[3] * m[6];
		
		inv[6] = -m[0]  * m[6] * m[15] + 
			m[0]  * m[7] * m[14] + 
			m[4]  * m[2] * m[15] - 
			m[4]  * m[3] * m[14] - 
			m[12] * m[2] * m[7] + 
			m[12] * m[3] * m[6];
		
		inv[10] = m[0]  * m[5] * m[15] - 
			m[0]  * m[7] * m[13] - 
			m[4]  * m[1] * m[15] + 
			m[4]  * m[3] * m[13] + 
			m[12] * m[1] * m[7] - 
			m[12] * m[3] * m[5];
		
		inv[14] = -m[0]  * m[5] * m[14] + 
			m[0]  * m[6] * m[13] + 
			m[4]  * m[1] * m[14] - 
			m[4]  * m[2] * m[13] - 
			m[12] * m[1] * m[6] + 
			m[12] * m[2] * m[5];
		
		inv[3] = -m[1] * m[6] * m[11] + 
			m[1] * m[7] * m[10] + 
			m[5] * m[2] * m[11] - 
			m[5] * m[3] * m[10] - 
			m[9] * m[2] * m[7] + 
			m[9] * m[3] * m[6];
		
		inv[7] = m[0] * m[6] * m[11] - 
			m[0] * m[7] * m[10] - 
			m[4] * m[2] * m[11] + 
			m[4] * m[3] * m[10] + 
			m[8] * m[2] * m[7] - 
			m[8] * m[3] * m[6];
		
		inv[11] = -m[0] * m[5] * m[11] + 
			m[0] * m[7] * m[9] + 
			m[4] * m[1] * m[11] - 
			m[4] * m[3] * m[9] - 
			m[8] * m[1] * m[7] + 
			m[8] * m[3] * m[5];
		
		inv[15] = m[0] * m[5] * m[10] - 
			m[0] * m[6] * m[9] - 
			m[4] * m[1] * m[10] + 
			m[4] * m[2] * m[9] + 
			m[8] * m[1] * m[6] - 
			m[8] * m[2] * m[5];
		
		det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];
		
		if (det == 0)
		{
			writeln("oops det is 0");
			for (i = 0; i < 16; i++)
				inv[i] = T.infinity;
		}
		else
		{
			det = 1.0 / det;
			
			for (i = 0; i < 16; i++)
				inv[i] = inv[i] * det;
		}
		return Matrix(inv);

	}

	public Matrix opBinary(string op)(Matrix rhs) 
	{
		static if( op == "*")
		{
			auto result = Matrix();

			for(int i = 0; i < 4; i++){ 
				for(int j = 0; j < 4; j++){ 
					T count = 0;

					for(int x = 0; x < 4; x++) 
					{
						count += this.m[i][x] * rhs.m[x][j]; 
					}

					result.m[i][j] = count;
				} 
			} 
			
			return result;
		}
	}

	public static Matrix createFromLookAt( Vector!T position,
	                                      Vector!T target,
	                                      Vector!T up )
	{
		Matrix mat;

		mat.up = up;
		mat.forward = Vector!T.normalize(target - position);
		mat.right = Vector!T.cross(mat.up, mat.forward);
		mat.translation = position;

		return mat;
	}

	public pure static Matrix createRotationX( T radians )
	{
		return Matrix(1, 			cos(radians), 	-sin(radians), 	0,
		              0, 			sin(radians), 	cos(radians), 	0,
		              0, 			0,				1, 				0,
		              0,			0,				0, 				1);
	}

	public pure static Matrix createRotationY( T radians )
	{
		return Matrix(cos(radians), 0, 	-sin(radians), 	0,
		              0, 			1, 	0, 				0,
		              sin(radians), 0,	cos(radians), 	0,
		              0,			0,	0, 				1);
	}

	public pure static Matrix createRotationZ( T radians )
	{
		return Matrix(cos(radians), -sin(radians), 	0, 0,
		              sin(radians), cos(radians), 	0, 0,
		              0, 			0,				1, 0,
		              0,			0,				0, 1);
	}

	public static Matrix createYawPitchRoll( T yaw, T pitch, T roll )
	{
		return createRotationZ(yaw) * createRotationY(pitch) * createRotationX( roll);
	}

	@property static pure immutable Matrix identity() nothrow
	{
		return Matrix(1, 0, 0, 0,
		              0, 1, 0, 0,
		              0, 0, 1, 0,
		              0, 0, 0, 1 );
	}

	
	@property Vector!T right() { return Vector!T(m[0]); }
	@property Vector!T up() { return Vector!T(m[1]); }
	@property Vector!T down() { return - Vector!T(m[1]); }
	@property Vector!T forward() { return Vector!T(m[2]); }
	@property Vector!T translation() { return Vector!T(m[3]); }

	@property void right( Vector!T value )
	{
		m[0] = value.elements;
	}

	@property void up( Vector!T value )
	{
		m[1] = value.elements;
	}

	
	@property void forward( Vector!T value )
	{
		m[2] = value.elements;
	}

	@property void translation( Vector!T value ) 
	{ 
		m[3] = value.elements;
	}

	private T[4][4] m;
}

