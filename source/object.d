module scene.object;

import source.colour;

struct SceneObject
{
	@property bool isTransparent() { return m_Transparent; }
	@property bool isReflective() { return m_Reflective; }
	@property Colour colour() { return m_Colour; }

private:
	Colour m_Colour;
	bool m_Transparent;
	bool m_Reflective;
};