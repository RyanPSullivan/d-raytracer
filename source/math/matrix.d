module math.matrix;

import math.vector;

class Matrix(T)
{

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

	
	T[4][4] m;
}

