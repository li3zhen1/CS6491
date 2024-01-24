
class Ray {
    PVector origin;
    PVector direction;

    Ray(PVector origin, PVector direction) {
        this.origin = origin;
        this.direction = direction;
    }

    void dump() {
        println("Ray");
        println("  origin: " + origin.x + " " + origin.y + " " + origin.z);
        println("  direction: " + direction.x + " " + direction.y + " " + direction.z);
    }


    public Hit intersect(Surface surface) {

        Tuple<PVector, PVector> result = null;

        int currentTriangleIndex = 0;

        for (int i = 0; i < surface.mesh.triangleCount(); i++) {
            var intersection = _intersect(surface, i);

            if (intersection != null) {
                if (debug_flag) {
                    println("point: " + intersection.first);
                }
                if (result == null) {
                    result = intersection;
                    currentTriangleIndex = i;
                } else {
                    var distance = PVector.dist(origin, intersection.first);
                    var closestDistance = PVector.dist(origin, result.first);
                    if (distance < closestDistance) {
                        result = intersection;
                        currentTriangleIndex = i;
                    }
                }
            }
        }
        if (result == null) {
            return null;
        }

        return new Hit(result.first, result.second, surface._color);
    }
    

    public Hit intersectWithShadow(Surface surface, SceneGraph sceneGraphRef) {

        var lights = sceneGraphRef.lights;
        var surfaces = sceneGraphRef.surfaces;

        Tuple<PVector, PVector> result = null;

        int currentTriangleIndex = 0;

        for (int i = 0; i < surface.mesh.triangleCount(); i++) {
            var intersection = _intersect(surface, i);

            if (intersection != null) {
                if (debug_flag) {
                    println("point: " + intersection.first);
                }
                if (result == null) {
                    result = intersection;
                    currentTriangleIndex = i;
                } else {
                    var distance = PVector.dist(origin, intersection.first);
                    var closestDistance = PVector.dist(origin, result.first);
                    if (distance < closestDistance) {
                        result = intersection;
                        currentTriangleIndex = i;
                    }
                }
            }
        }
        if (result == null) {
            return null;
        }

        var hit = new Hit(result.first, result.second, surface._color);

        var _color = new Color(0, 0, 0);

        // boolean hasLight = false;

        for (var light : lights) {
            var shadowRay = new Ray(hit.position, PVector.sub(light.position, hit.position));
            
            boolean hasObstacle = false;

            for (var surface2 : surfaces) {
                if (surface2 == surface) {
                    continue;
                }
                var _hit2 = shadowRay.intersect(surface2);
                if (_hit2 != null && _hit2.position.dist(hit.position) < light.position.dist(hit.position)) {
                    hasObstacle = true;
                    break;
                }
            }
            
            var lightDirection = PVector.sub(light.position, hit.position);
            lightDirection.normalize();

            var diffuse = hit.normal.dot(lightDirection);

            if (diffuse > 0 && !hasObstacle) {
                // hasLight = true;
                _color.r = _color.r + diffuse * light._color.r * hit._color.r;
                _color.g = _color.g + diffuse * light._color.g * hit._color.g;
                _color.b = _color.b + diffuse * light._color.b * hit._color.b;
            }
        }
        
        return new Hit(hit.position, hit.normal, _color);
    }


    // returns (point, normal)
    private Tuple<PVector, PVector> _intersect(Surface surface, int triangleIndex) {
        var tri = surface.mesh.getTriangleCopy(triangleIndex);
        var v1 = tri[0];
        var v2 = tri[1];
        var v3 = tri[2];
        var e1 = PVector.sub(v2, v1);
        var e2 = PVector.sub(v3, v1);

        var h = direction.cross(e2);
        var a = e1.dot(h);

        if (a > -1e-6 && a < 1e-6) {
            return null;
        }

        var f = 1.0 / a;
        var s = PVector.sub(origin, v1);
        var u = f * s.dot(h);

        if (u < 0.0 || u > 1.0) {
            return null;
        }

        var q = s.cross(e1);
        var v = f * PVector.dot(direction, q);

        if (v < 0.0 || u + v > 1.0) {
            return null;
        }

        var t = f * PVector.dot(e2, q);

        if (t > 0) {
            var point = PVector.add(origin, PVector.mult(direction, t));
            var normal = e1.cross(e2);
            normal.normalize();
            if (direction.dot(normal) > 0) {
                normal.mult(-1);
            }
            return new Tuple<PVector, PVector>(point, normal);
        } else {
            return null;
        }
    }
}
