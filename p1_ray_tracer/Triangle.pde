


final class Triangle implements IPrimitive {
    PVector v1;
    PVector v2;
    PVector v3;

    Triangle(PVector v1, PVector v2, PVector v3) {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
    }

    PartialHit _getIntersection(Ray ray, SceneGraph sg) {
        float closestHitT = Float.MAX_VALUE;
        
        PVector _e1 = new PVector();
        PVector _e2 = new PVector();
        PartialHit result = null;
        var rayDirection = ray.direction;
        var rayOrigin = ray.origin;
        
        // for (int i = 0; i < mesh.triangleCount(); i++) {
            
        //     var v1 = mesh.vertices.get(i * 3);
        //     var v2 = mesh.vertices.get(i * 3 + 1);
        //     var v3 = mesh.vertices.get(i * 3 + 2);
            var e1 = 
            PVector.sub(v2, v1);
            var e2 = 
            PVector.sub(v3, v1);

            var h = rayDirection.cross(e2);
            var a = e1.dot(h);

            if (a > -EPSILON && a < EPSILON) {
                return null;
            }

            var f = 1.0 / a;
            var s = PVector.sub(rayOrigin, v1);
            var u = f * s.dot(h);

            if (u < 0.0 || u > 1.0) {
                return null;
            }

            var q = s.cross(e1);
            var v = f * PVector.dot(rayDirection, q);

            if (v < 0.0 || u + v > 1.0) {
                return null;
            }

            var hitT = f * PVector.dot(e2, q);

        // }
        
        if (hitT > EPSILON && hitT < Float.MAX_VALUE) {
            var point = PVector.add(rayOrigin, PVector.mult(rayDirection, closestHitT));
            var normal = _e1.cross(_e2).normalize();
            if (rayDirection.dot(normal) > 0) {
                normal.mult(-1);
            }
            return new PartialHit(point, normal, closestHitT);
        } else {
            return null;
        }
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        // for (int i = 0; i < mesh.triangleCount(); i++) {
            
            // var v1 = mesh.vertices.get(i * 3);
            // var v2 = mesh.vertices.get(i * 3 + 1);
            // var v3 = mesh.vertices.get(i * 3 + 2);
            var e1 = PVector.sub(v2, v1);
            var e2 = PVector.sub(v3, v1);

            var h = ray.direction.cross(e2);
            var a = e1.dot(h);

            if (a > -EPSILON && a < EPSILON) {
                return false;
            }

            var f = 1.0f / a;
            var s = PVector.sub(ray.origin, v1);
            var u = f * s.dot(h);

            if (u < 0.0f || u > 1.0f) {
                return false;
            }

            var q = s.cross(e1);
            var v = f * PVector.dot(ray.direction, q);

            if (v < 0.0f || u + v > 1.0f) {
                return false;
            }

            var partialHit = f * PVector.dot(e2, q);

            if ( partialHit > EPSILON 
                && partialHit > mint 
                && partialHit < maxt) {
                return true;
            }
            return false;
        // }
        // return false;
    }
}