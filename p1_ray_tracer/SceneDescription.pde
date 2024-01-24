class SceneGraph {

    float fov;
    Color background;
    ArrayList<Light> lights;
    ArrayList<Surface> surfaces;

    ArrayList<Mat4x4> transformation = new ArrayList<Mat4x4>();



    SceneGraph() {
        this.fov = 0;
        this.background = new Color(0, 0, 0);
        this.lights = new ArrayList<Light>();
        this.surfaces = new ArrayList<Surface>();

        this.transformation.add(Mat4x4.identity());
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
