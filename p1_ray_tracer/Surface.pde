final class Surface {
    Color _color;
    Mesh mesh;
    // ArrayList<PVector> vertices;

    Surface(Color _color) {
        this._color = _color;
        this.mesh = new Mesh();
    }
}