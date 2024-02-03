final class SceneGraph {

    float fov;
    Color background;
    ArrayList<Light> lights;
    // ArrayList<Surface> surfaces;

    final HashMap<String, Surface> objectLibrary;
    
    final ArrayList<
        Surface
    > secneObjectInstances;

    final Surface getLatestObject() {
        return secneObjectInstances.get(secneObjectInstances.size() - 1);
    }

    // <T extends IRenderableObject>
    final void replaceLatestObject(Surface object) {
        secneObjectInstances.set(
            secneObjectInstances.size() - 1,
            object
        );
    }

    final void updatePrimitiveOfLatestObject(IPrimitive primitive) {
        var object = secneObjectInstances.get(secneObjectInstances.size() - 1);
        object.primitive = primitive;
    }

    final ArrayList<Mat4x4> transform = new ArrayList<Mat4x4>();

    final void moveLatestObjectToLibraryWithName(String name) {
        var object = secneObjectInstances.get(secneObjectInstances.size() - 1);
        objectLibrary.put(name, object);
        secneObjectInstances.remove(secneObjectInstances.size() - 1);
    }

    final void instantiate(String name) {
        var object = objectLibrary.get(name);
        
        secneObjectInstances.add(
            new InstancedSurface(
                object,
                getCurrentTransformCopy()
            )
        );
    }


    SceneGraph() {
        this.fov = 0;
        this.background = new Color(0, 0, 0);
        this.lights = new ArrayList<Light>();
        // this.surfaces = new ArrayList<Surface>();

        this.objectLibrary = new HashMap<String, Surface>();
        this.secneObjectInstances = new ArrayList<Surface>();

        this.transform.add(identityMat4x4());
    }

    final void push() {
        this.transform.add(
            getCurrentTransformCopy()
        );
    }

    final Mat4x4 getCurrentTransformRef() {
        return (this.transform.get(this.transform.size() - 1));
    }

    final Mat4x4 getCurrentTransformCopy() {
        return (this.transform.get(this.transform.size() - 1)).copy();
    }

    final void pop() {
        this.transform.remove(this.transform.size() - 1);
    }

    final void addObject(Surface object) {
        secneObjectInstances.add(
            object
        );
    }

    final void translate(float x, float y, float z) {
        Mat4x4 mat = translateMat4x4(x, y, z);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    final void scale(float x, float y, float z) {
        Mat4x4 mat = scaleMat4x4(x, y, z);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    final void rotateX(float angle) {
        Mat4x4 mat = rotateXMat4x4(angle);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    final void rotateY(float angle) {
        Mat4x4 mat = rotateYMat4x4(angle);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }

    final void rotateZ(float angle) {
        Mat4x4 mat = rotateZMat4x4(angle);
        this.transform.set(
            this.transform.size() - 1, 
            getCurrentTransformRef().dot(mat)
        );
    }



    final void dump() {
        println("SceneGraph");
        println("  fov: " + fov);
        println("  background: " + background.r + " " + background.g + " " + background.b);
        println("  lights: " + lights.size());
        for (int i = 0; i < lights.size(); i++) {
            Light light = lights.get(i);
            println("    light: " + light.position.x + " " + light.position.y + " " + light.position.z + " " + light._color.r + " " + light._color.g + " " + light._color.b);
        }
    }

}
