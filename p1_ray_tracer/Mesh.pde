class Mesh {
    ArrayList<PVector> vertices;

    Mesh(ArrayList<PVector> vertices) {
        vertices = new ArrayList<PVector>();
    }

    Mesh() {
        vertices = new ArrayList<PVector>();
    }

    void addVertex(PVector vertex) {
        vertices.add(vertex);
    }

    PVector getVertex(int index) {
        return vertices.get(index);
    }

    void setVertex(int index, PVector vertex) {
        vertices.set(index, vertex);
    }

    int triangleCount() {
        return vertices.size() / 3;
    }

    PVector[] getTriangleCopy(int index) {
        PVector[] triangle = new PVector[3];
        triangle[0] = vertices.get(index * 3);
        triangle[1] = vertices.get(index * 3 + 1);
        triangle[2] = vertices.get(index * 3 + 2);
        return triangle;
    }
    
}