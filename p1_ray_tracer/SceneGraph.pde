class SceneGraph {

    float fov;
    Color background;
    ArrayList<Light> lights;
    ArrayList<Surface> surfaces;
    ArrayList<Mat4x4> transform = new ArrayList<Mat4x4>();

    SceneGraph() {
        this.fov = 0;
        this.background = new Color(0, 0, 0);
        this.lights = new ArrayList<Light>();
        this.surfaces = new ArrayList<Surface>();

        this.transform.add(identityMat4x4());
    }

    void push() {
        this.transform.add(
            getCurrentTransformCopy()
        );
    }

    Mat4x4 getCurrentTransformRef() {
        return (this.transform.get(this.transform.size() - 1));
    }

    Mat4x4 getCurrentTransformCopy() {
        return (this.transform.get(this.transform.size() - 1)).copy();
    }

    void pop() {
        this.transform.remove(this.transform.size() - 1);
    }

    void translate(float x, float y, float z) {
        Mat4x4 mat = translateMat4x4(x, y, z);
        mat.dump();
        getCurrentTransformRef().dump();
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
        print("translate: " + x + " " + y + " " + z + " -> ");
        getCurrentTransformRef().dot(mat).dump();
    }

    void scale(float x, float y, float z) {
        Mat4x4 mat = scaleMat4x4(x, y, z);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    void rotateX(float angle) {
        Mat4x4 mat = rotateXMat4x4(angle);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    void rotateY(float angle) {
        Mat4x4 mat = rotateYMat4x4(angle);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    void rotateZ(float angle) {
        Mat4x4 mat = rotateZMat4x4(angle);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }



    void dump() {
        println("SceneGraph");
        println("  fov: " + fov);
        println("  background: " + background.r + " " + background.g + " " + background.b);
        println("  lights: " + lights.size());
        for (int i = 0; i < lights.size(); i++) {
            Light light = lights.get(i);
            println("    light: " + light.position.x + " " + light.position.y + " " + light.position.z + " " + light._color.r + " " + light._color.g + " " + light._color.b);
        }
        println("  surfaces: " + surfaces.size());
        for (int i = 0; i < surfaces.size(); i++) {
            Surface surface = surfaces.get(i);
            println("    surface: " + surface._color.r + " " + surface._color.g + " " + surface._color.b);
            println("      vertices: " + surface.vertices.size());
            for (int j = 0; j < surface.vertices.size(); j++) {
                PVector vertex = surface.vertices.get(j);
                println("        vertex: " + vertex.x + " " + vertex.y + " " + vertex.z);
            }
        }
    }

}
