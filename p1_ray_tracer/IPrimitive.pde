
public interface IPrimitive {
    PartialHit _getIntersection(Ray ray, SceneGraph sg);
    boolean hasIntersection(Ray ray, float mint, float maxt);

    Box getBoundingBox();
}

public interface IRenderableObject {
    Color getColor();
    PartialHit _getIntersection(Ray ray, SceneGraph sg);
    Hit getIntersection(Ray ray, SceneGraph sg);
    boolean hasIntersection(Ray ray, float mint, float maxt);
}


final class InstancedObject extends RenderableObject {

    // final Color _color;

    final PMatrix3D transform;
    final PMatrix3D invertedTransform;

    PartialHit _getIntersection(Ray ray, SceneGraph sg) {

        var transformedRay = ray.copyingTransformedBy(invertedTransform);
        var partialHit = super._getIntersection(transformedRay, sg);

        if (partialHit == null) {
            return null;
        }

        var normalTarget = transform.mult(
            PVector.add(partialHit.position, partialHit.normal), 
            null
        );
        partialHit.position = transform.mult(partialHit.position, null);
        partialHit.normal = PVector.sub(normalTarget, partialHit.position).normalize();

        return partialHit;
    }

    Hit getIntersection(Ray ray, SceneGraph sg) {
        var partialHit = _getIntersection(ray, sg);
        if (partialHit == null) {
            return null;
        }

        var resultColor = new Color(0.0, 0.0, 0.0);
        PVector pHit = partialHit.position;
        PVector normal = partialHit.normal;
        for(int i = 0; i < sg.lights.size(); i++) {
            Light light = sg.lights.get(i);
            PVector lightDir = PVector.sub(light.position, pHit);
            float length = lightDir.mag();
            // if (debug_flag) {
            //     println("lightDir: " + lightDir);
            // }
            PVector lightDirNormalized = lightDir.normalize();
            // println(lightDir, "-->", lightDirNormalized);//PVector.dist(light.position, pHit);
            Ray shadowRay = new Ray(pHit, lightDirNormalized /*lightDir.length()*/);
            boolean hasOcclusionTowardsThisRay = false;
            for(int j = 0; j < sg.secneObjectInstances.size(); j++) {
                
                if (sg.secneObjectInstances.get(j)
                        .hasIntersection(shadowRay, EPSILON, length)) {
                    hasOcclusionTowardsThisRay = true;
                    break;
                }
            }
            if (!hasOcclusionTowardsThisRay) {
                float cosTheta = normal.dot(lightDirNormalized);
                // println("cosTheta: " + cosTheta);
                if (cosTheta < 0) {
                    cosTheta = 0;// -cosTheta;
                }
                resultColor.r += super._color.r * light._color.r * cosTheta;
                resultColor.g += super._color.g * light._color.g * cosTheta;
                resultColor.b += super._color.b * light._color.b * cosTheta;
            }
        }

        return new Hit(pHit, normal, resultColor);
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        return super.hasIntersection(
            ray.copyingTransformedBy(invertedTransform), mint, maxt
        );
    }

    public InstancedObject(
        RenderableObject namedObject, 
        Mat4x4 transform,
        Color _color
    ) {
        super(_color, namedObject.primitive);
        this.transform = transform.toPMatrix3D();
        
        var pMat = transform.toPMatrix3D();
        if (!pMat.invert()) {
            throw new RuntimeException("Matrix not invertible");
        }
        this.invertedTransform = pMat;

        invertedTransform.print();
    }

    public InstancedObject(
        RenderableObject namedObject, 
        Mat4x4 transform
    ) {
        super(namedObject._color, namedObject.primitive);
        this.transform = transform.toPMatrix3D();
        
        var pMat = transform.toPMatrix3D();
        if (!pMat.invert()) {
            throw new RuntimeException("Matrix not invertible");
        }
        this.invertedTransform = pMat;

        invertedTransform.print();
    }
}




static float EPSILON = 1e-5f;
