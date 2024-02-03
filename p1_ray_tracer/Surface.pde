final class Surface implements IRenderableObject {
    Color _color;
    Mesh mesh;
    
    Surface(Color _color) {
        this._color = _color;
        this.mesh = new Mesh();
    }

    Color getColor() {
        return _color;
    }

    PartialHit intersectionWithTriangleStartingAt(
        Ray ray, 
        int triangleIndex
    ) {
        
        var v1 = mesh.vertices.get(triangleIndex * 3);
        var v2 = mesh.vertices.get(triangleIndex * 3 + 1);
        var v3 = mesh.vertices.get(triangleIndex * 3 + 2);
        var e1 = PVector.sub(v2, v1);
        var e2 = PVector.sub(v3, v1);

        var h = ray.direction.cross(e2);
        var a = e1.dot(h);

        if (a > -EPSILON && a < EPSILON) {
            return null;//Float.MAX_VALUE;
        }

        var f = 1.0 / a;
        var s = PVector.sub(ray.origin, v1);
        var u = f * s.dot(h);

        if (u < 0.0 || u > 1.0) {
            return null;//Float.MAX_VALUE;
        }

        var q = s.cross(e1);
        var v = f * PVector.dot(ray.direction, q);

        if (v < 0.0 || u + v > 1.0) {
            return null;//Float.MAX_VALUE;
        }

        var t = f * PVector.dot(e2, q);

        // return t;

        if (debug_flag) {
            println("t: " + t);
        }

        if (t > EPSILON) {
            var point = PVector.add(ray.origin, PVector.mult(ray.direction, t));
            var normal = e1.cross(e2).normalize();
            if (ray.direction.dot(normal) > 0) {
                normal.mult(-1);
            }
            return new PartialHit(point, normal, t);
        } else {
            return null;
        }
    }




    float _intersectionWithTriangleStartingAt(
        Ray ray, 
        int triangleIndex
    ) {
        
        var v1 = mesh.vertices.get(triangleIndex * 3);
        var v2 = mesh.vertices.get(triangleIndex * 3 + 1);
        var v3 = mesh.vertices.get(triangleIndex * 3 + 2);
        var e1 = PVector.sub(v2, v1);
        var e2 = PVector.sub(v3, v1);

        var h = ray.direction.cross(e2);
        var a = e1.dot(h);

        if (a > -EPSILON && a < EPSILON) {
            return Float.MAX_VALUE;
        }

        var f = 1.0 / a;
        var s = PVector.sub(ray.origin, v1);
        var u = f * s.dot(h);

        if (u < 0.0 || u > 1.0) {
            return Float.MAX_VALUE;
        }

        var q = s.cross(e1);
        var v = f * PVector.dot(ray.direction, q);

        if (v < 0.0 || u + v > 1.0) {
            return Float.MAX_VALUE;
        }

        var t = f * PVector.dot(e2, q);

        return t;

        // if (debug_flag) {
        //     println("t: " + t);
        // }

        // if (t > EPSILON) {
        //     var point = PVector.add(ray.origin, PVector.mult(ray.direction, t));
        //     var normal = e1.cross(e2).normalize();
        //     if (ray.direction.dot(normal) > 0) {
        //         normal.mult(-1);
        //     }
        //     return new PartialHit(point, normal, t);
        // } else {
        //     return null;
        // }
    }




    PartialHit _getIntersection(Ray ray, SceneGraph sg) {
        float closestHitT = Float.MAX_VALUE;
        // PVector e1 = new PVector();
        // PVector e2 = new PVector();
        PVector _e1 = new PVector();
        PVector _e2 = new PVector();
        PartialHit result = null;
        // PVector h = new PVector(0.0, 0.0, 0.0);
        for (int i = 0; i < mesh.triangleCount(); i++) {
            
            var v1 = mesh.vertices.get(i * 3);
            var v2 = mesh.vertices.get(i * 3 + 1);
            var v3 = mesh.vertices.get(i * 3 + 2);
            var e1 = 
            PVector.sub(v2, v1);
            var e2 = 
            PVector.sub(v3, v1);

            var h = ray.direction.cross(e2);
            var a = e1.dot(h);

            if (a > -EPSILON && a < EPSILON) {
                continue;
            }

            var f = 1.0 / a;
            var s = PVector.sub(ray.origin, v1);
            var u = f * s.dot(h);

            if (u < 0.0 || u > 1.0) {
                continue;
            }

            var q = s.cross(e1);
            var v = f * PVector.dot(ray.direction, q);

            if (v < 0.0 || u + v > 1.0) {
                continue;
            }

            var hitT = f * PVector.dot(e2, q);

            if (hitT < closestHitT) {
                closestHitT = hitT;
                _e1 = e1;
                _e2 = e2;
            }

        }
        
        if (closestHitT > EPSILON && closestHitT < Float.MAX_VALUE) {
            var point = PVector.add(ray.origin, PVector.mult(ray.direction, closestHitT));
            var normal = _e1.cross(_e2).normalize();
            if (ray.direction.dot(normal) > 0) {
                normal.mult(-1);
            }
            return new PartialHit(point, normal, closestHitT);
        } else {
            return null;
        }
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

            
            PVector lightDirNormalized = lightDir.normalize();


            float length = lightDir.mag();

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
                resultColor.r += _color.r * light._color.r * cosTheta;
                resultColor.g += _color.g * light._color.g * cosTheta;
                resultColor.b += _color.b * light._color.b * cosTheta;
            }
        }
        return new Hit(pHit, normal, resultColor);
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        for (int i = 0; i < mesh.triangleCount(); i++) {
            // float partialHit = _intersectionWithTriangleStartingAt(ray, i);

            var v1 = mesh.vertices.get(i * 3);
            var v2 = mesh.vertices.get(i * 3 + 1);
            var v3 = mesh.vertices.get(i * 3 + 2);
            var e1 = PVector.sub(v2, v1);
            var e2 = PVector.sub(v3, v1);

            var h = ray.direction.cross(e2);
            var a = e1.dot(h);

            if (a > -EPSILON && a < EPSILON) {
                continue;
            }

            var f = 1.0 / a;
            var s = PVector.sub(ray.origin, v1);
            var u = f * s.dot(h);

            if (u < 0.0 || u > 1.0) {
                continue;
            }

            var q = s.cross(e1);
            var v = f * PVector.dot(ray.direction, q);

            if (v < 0.0 || u + v > 1.0) {
                continue;
            }

            var partialHit = f * PVector.dot(e2, q);

            if ( partialHit > EPSILON 
                && partialHit > mint 
                && partialHit < maxt) {
                return true;
            }
        }
        return false;
    }
}


// static final class _Surface implements IRenderableObject {
//     enum SurfaceKind {
//         // EMPTY,
//         MESH,
//         BOX
//     };

//     SurfaceKind _kind;

//     Color _color;


//     Mesh mesh = null;
//     Box box = null;

//     _Surface(Color _color) {
//         this._color = _color;
//         this.mesh = new Mesh();
//         this._kind = SurfaceKind.MESH;
//     }

//     void convertToBox(Box box) {
//         this.box = box;
//         this._kind = SurfaceKind.BOX;
//     }
    
//     Hit getIntersection(Ray ray, SceneGraph sg) {
//         return null;
//     }

//     boolean hasIntersection(Ray ray, float mint, float maxt) {
//         return false;
//     }
// }