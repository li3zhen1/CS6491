final class Surface implements IRenderableObject {
    Color _color;
    Mesh mesh;
    // ArrayList<PVector> vertices;

    Surface(Color _color) {
        this._color = _color;
        this.mesh = new Mesh();
    }


    Hit getIntersection(Ray ray, SceneGraph sg) {
        return null;
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        return false;
    }
}