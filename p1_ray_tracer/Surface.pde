class Surface {
    Color _color;
    ArrayList<PVector> vertices;

    Surface(Color _color) {
        this._color = _color;
        this.vertices = new ArrayList<PVector>();
    }

    private PVector getVertex(int index) {
        return vertices.get(index);
    }
}