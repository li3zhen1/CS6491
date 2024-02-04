


class RenderableObject {
    Color _color;

    // boolean accelerated = false;
    
    IPrimitive primitive;

    void accelerate() {
        if (primitive instanceof Mesh) {
            Mesh mesh = (Mesh)primitive;
            var triangles = new ArrayList<Triangle>(mesh.triangleCount());
            for (int i = 0; i < mesh.triangleCount(); i++) {
                var v1 = mesh.vertices.get(i * 3);
                var v2 = mesh.vertices.get(i * 3 + 1);
                var v3 = mesh.vertices.get(i * 3 + 2);
                triangles.add(new Triangle(v1, v2, v3));
            }
            var ga = new BVHAcceleration<Triangle>(
                                new Box(mesh.pMin,
                mesh.pMax),
                triangles,
                0
            );
            ga.recursiveSplit();
            // ga.dump();
            primitive = ga;
            println("accelerated");
        }
    }

    RenderableObject(Color _color, IPrimitive primitive) {
        this._color = _color;
        this.primitive = primitive;
    }

    Color getColor() {
        return _color;
    }

    PartialHit _getIntersection(Ray ray, SceneGraph sg) {
        return this.primitive._getIntersection(ray, sg);
        
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        return this.primitive.hasIntersection(ray, mint, maxt);
        
    }
    Hit getIntersection(Ray ray, SceneGraph sg) {
        PartialHit partialHit = _getIntersection(ray, sg);
        
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
            
            PVector lightDirNormalized = lightDir.normalize();

            Ray shadowRay = new Ray(pHit, lightDirNormalized /*lightDir.length()*/);
            boolean hasOcclusionTowardsThisRay = false;
            for(int j = 0; j < sg.secneObjectInstances.size(); j++) {
                if (sg.secneObjectInstances.get(j).hasIntersection(shadowRay, EPSILON, length /*lightDir.length()*/)) {
                    hasOcclusionTowardsThisRay = true;
                    break;
                }
            }
            if (!hasOcclusionTowardsThisRay) {
                float cosTheta = normal.dot(lightDirNormalized);
                // println("cosTheta: " + cosTheta);
                if (cosTheta < 0) {
                    cosTheta = 0;//-cosTheta;
                }
                if (debug_flag) {
                    println("cosTheta: " + cosTheta);
                    println("normal: " + normal);
                    println("lightDirNormalized: " + lightDirNormalized);
                    println("color: " + _color.r + " " + _color.g + " " + _color.b);
                    println("lightColor: " + light._color.r + " " + light._color.g + " " + light._color.b);
                    
                }
                resultColor.r += _color.r * light._color.r * cosTheta;
                resultColor.g += _color.g * light._color.g * cosTheta;
                resultColor.b += _color.b * light._color.b * cosTheta;
            }
        }
        return new Hit(pHit, normal, resultColor);
    }

}

