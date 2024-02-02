public interface IRenderableObject {
    Hit getIntersection(Ray ray, SceneGraph sg);
    boolean hasIntersection(Ray ray, float mint, float maxt);
}

class NamedObject<T extends IRenderableObject> {
    String name; 
    T object;
}


static float EPSILON = 1e-5f;
